# AI Coworker

An execution-oriented DeepSeek workspace: give a goal, assign or auto-hire a coworker, run an action loop, review checkpoints and download actual files. Not a clone of a commercial product.

## Open the website

Expected GitHub Pages URL after deployment: https://tbenitz.github.io/AI-Coworker/

In GitHub, open **Settings → Pages → Build and deployment → Deploy from a branch**, select **main / (root)**, and save. The static site has no build dependency. You can also open index.html through a local static web server.

1. Get an API key from https://platform.deepseek.com/api_keys.
2. Open Settings in the website. Enter your key and select the model (default deepseek-flash; deepseek-v4-pro also supported).
3. Return to Overview, enter a goal, and run. The browser runtime executes text-file and memory actions, hires coworkers, and asks before overwriting/deleting files.
4. View Tasks & activity and Approvals. Download real artifacts from Files & memory.

Browser keys are session-only. Browser storage is local to this device, not shared across users. Direct DeepSeek browser access depends on provider CORS; if it fails, use the server.

## Persistent runtime (recommended)

Requires Node.js 22+ and a private server or always-on computer. No npm dependencies for core functionality.

    git clone https://github.com/tbenitz/AI-Coworker.git
    cd AI-Coworker
    cp .env.example .env
    # Edit .env with your API key and a long random access token.
    node --env-file=.env server.js

Open http://localhost:8080, go to Settings, leave runtime URL blank, enter the COWORKER_TOKEN, and Connect runtime. DeepSeek runs on the server using DEEPSEEK_API_KEY. For a remote HTTPS server, enter the server URL in the Pages website and set CORS_ORIGINS=https://tbenitz.github.io on the server. Prefer a private VPN or HTTPS reverse proxy. Keep the runtime online and DATA_DIR on a durable volume. Do not expose a raw HTTP server to the public internet.

Docker alternative:

    docker build -t ai-coworker .
    docker run --env-file .env -e HOST=0.0.0.0 -p 127.0.0.1:8080:8080 -v coworker-data:/app/data ai-coworker

The shared server workspace persists jobs, logs, memory, files, approvals, coworker definitions and schedules. A trusted team can share the same token; individual identities, invitations, role separation and per-user audit attribution are not implemented. Treat this as a single trusted-workspace prototype. Never share the token with untrusted users. Connected app data and task content may be sent to DeepSeek. Do not use sensitive production data without appropriate authorization and security review.

## App connections

Set only the credentials you need in the server environment. Restart after edits. A configured badge means the credential is present, not that the service has validated it. API scope, token expiration, account plans and provider rate limits still apply.

| Environment variable | Actual operations |
|---|---|
| GMAIL_ACCESS_TOKEN | List/read recent Gmail messages; send one approved email. OAuth access token with suitable scopes; manual refresh required. |
| SLACK_BOT_TOKEN | List channels; post an approved message. |
| NOTION_TOKEN | Search shared pages; create an approved child page. |
| STRIPE_READ_KEY | Read recent payment intents using a restricted read key. No payment execution. |
| HUBSPOT_TOKEN | Read contacts; create an approved contact. |
| APOLLO_API_KEY | Approved credit-consuming known business contact lookup by email. |
| PROSPEO_API_KEY | Approved credit-consuming verified business email enrichment. |
| CLAY_WEBHOOK_URL | Approved JSON delivery to a configured Clay webhook. |
| OUTBOUND_WEBHOOK_URL | Approved JSON delivery to an administrator-configured HTTPS webhook (can connect to external automation providers). |
| BRAVE_SEARCH_KEY | Public web search for research. |
| BROWSER_ORIGINS | Optional allowlisted HTTPS origins for browser snapshots. |

No keys go into the public repository. OAuth login/refresh flows, 3,000 native apps, phone reveal, LinkedIn and WhatsApp messaging are not implemented. Use the generic webhook bridge only with trusted destinations and clear approval policies. API integration calls have not been tested against live provider credentials.

## Automations

In connected server mode, create a recurring interval in minutes (5 minimum), or a named webhook trigger. Interval scheduling runs while the tab is closed as long as the runtime is online. It is an interval scheduler, not a cron/calendar scheduler.

Set WEBHOOK_TOKEN to a separate random secret. An authenticated caller or an integration relay can trigger a task:

    curl -X POST https://YOUR_RUNTIME/api/webhook \
      -H "Authorization: Bearer YOUR_WEBHOOK_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"event":"stripe.payment_failed","payload":{"example":"event data"}}'

Native Stripe signature validation and Gmail push subscriptions are not included. Use a trusted relay that verifies provider events. Treat event data and app content as untrusted. Webhook deliveries are not deduplicated.

## Computer

Optional on a trusted dedicated runtime:

    npm install playwright
    npx playwright install chromium

Set BROWSER_ORIGINS to comma-separated exact HTTPS origins you trust (including required asset origins if necessary). The browser allows GET requests only to allowlisted origins; capture screenshots and read page text, and view runtime diagnostics. This is not a live desktop, full browser takeover or general terminal. Do not give untrusted origins access to private network services. For production use a separate network-isolated browser sandbox.

## Execution and safety

The model produces bounded JSON actions, the engine executes actual actions, and records tool results. External writes, billable enrichment, overwrites and deletions need explicit per-action approval; Stripe is read-only. Approval is not permanent or session-wide. Jobs can be paused, resumed and inspected. There is a 30-step limit per run; review before resuming. Model calls and external actions can fail. If the runtime stops during a write, check external state before retrying: exactly-once execution is not guaranteed.

## Development

    node --check engine.js
    node --check app.js
    node --check server.js
    node test.js

Mock execution checks cover file creation, approval-gated overwrite, resumption and declined deletion. A real DeepSeek key and external app credentials are required for live integration tests.

## Status

- [x] Responsive workspace, settings, task timeline, real text artifacts, shared memory.
- [x] Bounded action loop, auto-hire/assign, approval and resume.
- [x] Persistent single-workspace runtime, interval and authenticated webhook triggers.
- [x] Initial app adapters, optional web search and browser snapshots.
- [ ] Live provider integration testing and deployed cloud runtime.
- [ ] Full browser/terminal computer, takeover, isolated worker sandbox.
- [ ] Individual team accounts, invitation links, roles, scoped standing approvals.
- [ ] Full connector marketplace, OAuth and calendar/cron scheduling.

DeepSeek API reference: https://api-docs.deepseek.com/

## v2 — Plan first, no intake questionnaire

Use **Generate plan** to create and save a complete Markdown plan from a single goal. **Run coworker** automatically detects planning requests and otherwise generates a working plan before acting. The plan specifies objectives, assumptions, actionable steps, owners, timing, deliverables, success metrics, risks/resources, and the immediate next action. Invalid plan responses are retried up to three attempts, with larger output limits when needed. Routine questions are suppressed; sensitive external writes and destructive actions still require approval. For a legacy task, open it and select **Generate plan from existing answers** to create a new plan task that preserves the original task and reuses its previous answers. No new questions are necessary. If the model repeatedly ignores execution instructions, the task stops with an error and retains its plan. The plan schema checks structure, not factual accuracy; live model output and external integration results still require review.
