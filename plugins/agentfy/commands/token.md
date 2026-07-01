---
description: Update or re-enter your Agentfy API token (rotate/reconnect the plugin)
argument-hint: [new-token]
---

You are helping the user update the **Agentfy** plugin's API token — for example after they
regenerated it in the Agentfy iOS app, or if notifications stopped working.

New token they passed (may be empty): `$ARGUMENTS`

## If they provided a token
It should look like a UUID (for example `412838DE-1652-4028-B701-FD62D740E914`). Update the stored
config by running exactly this in the shell:

```
claude plugin install agentfy@agentfy --config api_token=<the token they provided>
```

Then tell them to run `/reload-plugins` (or restart Claude Code) to apply it, and confirm when it's
done. The token is saved to their OS keychain, not in plaintext. Do not echo the full token back.

## If they did NOT provide a token
Show them how to update it, concisely:

1. **Get your token** from the Agentfy app: **Settings → Configure Claude Code**. Tapping
   **Regenerate Token** copies the new one to your clipboard automatically.
2. **Update the plugin** — pick one:
   - run `/agentfy:token <paste-your-token>` (this command, with the token), **or**
   - run `claude plugin install agentfy@agentfy --config api_token=<YOUR_TOKEN>`, **or**
   - `/plugin` → **Installed** → **agentfy** → **Configure** → paste → **Save**
3. **Apply it** with `/reload-plugins` (or restart Claude Code).

Keep it short and actionable.
