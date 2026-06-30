#!/usr/bin/env sh
# Agentfy — Claude Code event forwarder.
#
# Reads a Claude Code hook event (JSON on stdin), optionally trims the prompt to
# a short preview *on this machine*, and POSTs it to the Agentfy webhook so the
# iOS app can show session status and send notifications / Live Activities.
#
# Best-effort by design: this never blocks Claude Code. If anything is missing
# (no token, no jq/curl, network down) it silently exits 0.
#
# Open source — read exactly what gets sent: https://github.com/ibrillantes/claude-code-plugin
set -u

EVENT="${1:-}"

# Webhook endpoint. Override only for local testing/staging; production uses the default.
URL="${AGENTFY_WEBHOOK_URL:-https://webhook.getagentfy.com}"

# Per-user values collected by the plugin's config dialog (userConfig).
# api_token is stored in the OS keychain (sensitive:true), never in plaintext settings.
TOKEN="${CLAUDE_PLUGIN_OPTION_API_TOKEN:-}"
PREVIEW="${CLAUDE_PLUGIN_OPTION_PROMPT_PREVIEW:-true}"

# Not configured yet (e.g. before the user fills in the dialog), or tools missing: no-op.
[ -n "$TOKEN" ] || exit 0
command -v jq   >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

# Data minimization, done locally before anything is sent:
#  - tag the event name
#  - from tool_input, keep ONLY the small details the app shows (command,
#    file_path, pattern, prompt) and DROP everything else — most importantly the
#    code in an Edit/Write (new_string/old_string/content) never leaves the machine.
TRIM='. + {hook_event_name: $ev}
  | (if (.tool_input | type) == "object"
       then .tool_input |= ({command, file_path, pattern, prompt} | with_entries(select(.value != null)))
       else . end)'

if [ "$EVENT" = "UserPromptSubmit" ] && [ "$PREVIEW" = "true" ]; then
  # Keep only the first 30 characters of the prompt. Truncated HERE, locally,
  # before the payload ever leaves this machine.
  FILTER="$TRIM | .prompt = ((.prompt // \"\") | .[0:30])"
elif [ "$EVENT" = "UserPromptSubmit" ]; then
  # Preview off: never transmit any prompt text.
  FILTER="$TRIM | del(.prompt)"
else
  FILTER="$TRIM"
fi

jq -c --arg ev "$EVENT" "$FILTER" 2>/dev/null \
  | curl -s -m 5 -X POST "$URL" \
      -H "Authorization: Bearer $TOKEN" \
      -H 'Content-Type: application/json' \
      --data-binary @- >/dev/null 2>&1 || true

exit 0
