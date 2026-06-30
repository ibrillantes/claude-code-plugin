# agentfy plugin

Forwards Claude Code session lifecycle events to [Agentfy](https://getagentfy.com) so you get
iPhone notifications and Live Activities for your agents.

## How it works

`hooks/hooks.json` registers one command hook per lifecycle event. Each runs
[`hooks/send-event.sh`](hooks/send-event.sh), which:

1. Reads the hook event JSON from stdin.
2. For `UserPromptSubmit`, trims the prompt to a 30-char preview **locally** (or strips it entirely
   if you turned the preview off).
3. POSTs the payload to `https://webhook.getagentfy.com` with your token as a bearer header.

It's best-effort: if the token isn't set, or `jq`/`curl` are missing, or the network is down, it
silently does nothing and never blocks Claude Code.

## Configuration (`userConfig`)

Collected by Claude Code's plugin dialog when you enable the plugin:

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `api_token` | string (sensitive, required) | — | Your Agentfy token. Stored in the OS keychain. |
| `prompt_preview` | boolean | `true` | Send the first 30 chars of each prompt (trimmed locally). |

At runtime these are exposed to the script as `CLAUDE_PLUGIN_OPTION_API_TOKEN` and
`CLAUDE_PLUGIN_OPTION_PROMPT_PREVIEW`.

## Events → app state

| Hook event | App state |
| --- | --- |
| `SessionStart` | new agent |
| `UserPromptSubmit`, `PreToolUse`, `PreCompact` | working |
| `Stop`, `Notification`, `PermissionRequest` | needs you |
| `SessionEnd` | offline |

## Testing locally

```sh
# Point the script at a local listener instead of production:
export AGENTFY_WEBHOOK_URL="http://127.0.0.1:8787"
export CLAUDE_PLUGIN_OPTION_API_TOKEN="<a-real-test-token>"
export CLAUDE_PLUGIN_OPTION_PROMPT_PREVIEW="true"

echo '{"session_id":"t","prompt":"a very long prompt that exceeds thirty characters for sure"}' \
  | ./hooks/send-event.sh UserPromptSubmit
```
