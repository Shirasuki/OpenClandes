# Security Notes

## Treat the Safe Entry as a Secret

`CLANDES_SAFE_ENTRY` protects standalone HTTP deployments by hiding `/v1/...` behind a high-entropy path prefix.

Use a random value:

```bash
printf '/s_%s\n' "$(openssl rand -hex 16)"
```

Avoid obvious values such as `/api`, `/admin`, `/clandes`, or user names.

The safe entry may appear in reverse proxy access logs, browser history, monitoring labels, and shell history. Treat it like a bearer credential.

## Protect RPC

If RPC is reachable outside a trusted local machine or private network, set:

```bash
RPC_AUTH_TOKEN=...
```

Bind RPC to loopback whenever possible:

```bash
RPC_LISTEN_ADDR=127.0.0.1:8082
```

## Protect Stored Data

The account database may contain OAuth refresh tokens and API keys.

Do not publish:

- account database files
- dump directories
- `.env` files
- OAuth access/refresh tokens
- API keys
- proxy credentials

## Debug Dumps

`CLANDES_DUMP_MESSAGES_DIR`, `CLANDES_DUMP_MESSAGES_JSON`, and `CLANDES_DUMP_UNREDACTED` are local debugging tools.

Do not enable unredacted dumps in shared or production environments.
