# RPC Integration

Clandes exposes its management and decision APIs through Cap'n Proto RPC.

The protocol files live in [`../schema`](../schema):

| File | Purpose |
| --- | --- |
| `clandes.capnp` | bootstrap and root service |
| `account.capnp` | account registration, update, listing, removal |
| `policy.capnp` | external decision service routing and event stream |
| `proxy.capnp` | proxy probing |
| `claude_auth.capnp` | Claude OAuth login and refresh |
| `claude_query.capnp` | Claude profile, usage, role queries |
| `codex_auth.capnp` | ChatGPT/Codex OAuth login, refresh, revoke |
| `codex_query.capnp` | Codex account profile query |
| `common.capnp` | shared structs/enums |

## Authentication

The bootstrap call accepts a token string. If the server has `RPC_AUTH_TOKEN` set, clients must pass the same value.

If `RPC_AUTH_TOKEN` is empty, RPC auth is disabled. Only do this on a trusted local interface.

## Policy Routing

In decision-service mode, HTTP requests are not routed locally. A policy client connects to the policy service and receives route tasks containing:

- request ID
- inbound API credential
- model
- endpoint
- user agent
- session ID
- client request ID

The policy client replies with either:

- a target `account_id`
- optional model/thinking overrides
- rejection status and message

If no policy client is connected and standalone mode is disabled, HTTP requests return no-route errors.

## Events

The policy service also receives usage and account events:

- usage reports for completed or failed requests
- OAuth refresh/account lifecycle events
- stream usage chunks for SSE responses

These events are intended for billing, monitoring, and cleanup logic.

## Generating Client Code

Download the release schema package or use the checked-in `schema/` directory:

```bash
tar -xzf clandes-capnp-schemas-0.1.5.tar.gz -C ./schema
```

Then run the Cap'n Proto generator for your language/runtime.
