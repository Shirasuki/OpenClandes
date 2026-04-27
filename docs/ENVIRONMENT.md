# Environment Variables

## Listener and Security

| Variable | Default | Description |
| --- | --- | --- |
| `API_LISTEN_ADDR` | `0.0.0.0:8080` | HTTP API listen address |
| `RPC_LISTEN_ADDR` | `127.0.0.1:8082` | Cap'n Proto RPC listen address |
| `RPC_AUTH_TOKEN` | empty | Bearer token for RPC auth. Set this if RPC is reachable outside a trusted local environment |
| `CLANDES_SAFE_ENTRY` | empty | Secret HTTP path prefix. Required when `STANDALONE_MODE=1` |

## Routing

| Variable | Default | Description |
| --- | --- | --- |
| `STANDALONE_MODE` | false | Enables local routing when no decision service is connected |
| `ROUTE_STRATEGY` | `random` | Standalone account selection. Supports `random`, `round_robin`, `roundrobin` |
| `SESSION_ID_NAMESPACE_MARKER` | built-in | Namespace marker used when deriving upstream session IDs |

## Persistence and Refresh

| Variable | Default | Description |
| --- | --- | --- |
| `CLANDES_ACCOUNT_DB` | default path | redb account database path. `0`, `off`, or `none` disables persistence |
| `OAUTH_BACKGROUND_REFRESH_INTERVAL_SECS` | `60` | OAuth background refresh scan interval. `0` disables the task |

Default account database path:

- `$XDG_DATA_HOME/clandes/accounts.redb`
- `$HOME/.local/share/clandes/accounts.redb`
- fallback: `./clandes-data/accounts.redb`

## Performance

| Variable | Default | Description |
| --- | --- | --- |
| `CLIENT_POOL_SIZE` | `4` | Upstream HTTP client pool size per account |
| `SIGNATURE_CACHE_CAPACITY` | `131072` | Billing signature cache capacity |

## Debugging

| Variable | Description |
| --- | --- |
| `RUST_LOG` | tracing filter, for example `info` |
| `CLANDES_DUMP_MESSAGES_DIR` | writes Messages exchanges to a directory. May contain sensitive data |
| `CLANDES_DUMP_MESSAGES_JSON` | logs normalized Messages JSON through tracing |
| `CLANDES_DUMP_UNREDACTED` | disables redaction in dumps. Use only for local debugging |
| `CLANDES_BLOCK_ANTHROPIC_UPSTREAM` | blocks Anthropic Messages upstream sends |
| `TEST_PROXY_URL` | SOCKS5 proxy URL used by proxy tests |
