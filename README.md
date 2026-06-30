# Agentfy — Claude Code plugin marketplace

Monitor your [Claude Code](https://claude.com/claude-code) agents from your phone. Get an iPhone notification or Live Activity the moment an agent starts, stops, or needs your input.

This repo is both the **plugin marketplace** and the home of the open-source **`agentfy`** plugin. It's public on purpose — you can read exactly what gets sent to Agentfy (see [`plugins/agentfy/hooks/send-event.sh`](plugins/agentfy/hooks/send-event.sh)).

## Install

You need the [Agentfy iOS app](https://getagentfy.com) to get your API token, and Claude Code v2.1.143+.

```text
/plugin marketplace add ibrillantes/claude-code-plugin
/plugin install agentfy@agentfy
```

When prompted, paste your **API token** (Agentfy app → Settings → Configure Claude Code). Then run `/reload-plugins` (or restart Claude Code) and send any message — your phone will light up.

## What it does

The plugin registers Claude Code hooks for these lifecycle events:

`SessionStart` · `UserPromptSubmit` · `PreToolUse` · `PermissionRequest` · `Stop` · `Notification` · `PreCompact` · `SessionEnd`

On each event it POSTs a small JSON status payload to `https://webhook.getagentfy.com`, authenticated with your per-user token. The app turns those into status, notifications, and Live Activities.

## Privacy

- **No code or file contents are ever sent** — only session metadata (event name, session id, project name, the tool involved).
- **Prompt preview is optional and truncated locally.** With "Send a short prompt preview" on (default), only the **first 30 characters** of each prompt are sent — and the truncation happens on *your* machine, in [`send-event.sh`](plugins/agentfy/hooks/send-event.sh), before anything leaves it. Turn it off to send no prompt text at all.
- **Your token is stored in your OS keychain** (the plugin config marks it `sensitive`), never in plaintext `settings.json`.

## Requirements

- Claude Code v2.1.143 or later (for the plugin config dialog).
- `jq` and `curl` on your `PATH` (standard on macOS; install via your package manager on Linux).
- macOS or Linux. (Windows isn't supported by this script yet — use the in-app manual setup as a fallback.)

## Updates

We bump the plugin `version` on each release. Run `/plugin update agentfy` to get the latest, or enable auto-update for this marketplace.

## License

MIT — see [LICENSE](LICENSE).
