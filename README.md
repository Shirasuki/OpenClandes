# OpenClandes

OpenClandes is the public documentation and protocol-contract repository for Clandes.

This repository intentionally does **not** publish the server source code. It contains only:

- user-facing deployment and operation docs
- integration docs for external decision/policy clients
- Cap'n Proto RPC schemas under [`schema/`](schema/)
- release assets packaging those schemas

## What Clandes Does

Clandes is an AI account gateway. API clients send Anthropic or OpenAI/Codex-shaped requests to a Clandes HTTP endpoint; Clandes routes the request to a registered upstream account.

Supported inbound HTTP APIs:

| Endpoint | Purpose |
| --- | --- |
| `POST /v1/messages` | Anthropic Messages |
| `POST /v1/messages/count_tokens` | Anthropic token counting |
| `POST /v1/responses` | OpenAI Responses / Codex |
| `POST /v1/responses/compact` | Codex conversation compaction |
| `POST /v1/chat/completions` | OpenAI Chat Completions |

## Start Here

- [Usage Guide](docs/USAGE.md): deploy the image, configure the safe entry, register accounts, point clients at Clandes.
- [Environment Variables](docs/ENVIRONMENT.md): server configuration reference.
- [RPC Integration](docs/RPC.md): how external decision clients use the Cap'n Proto APIs.
- [Security Notes](docs/SECURITY.md): safe-entry and credential handling guidance.
- [Schema Directory](schema/README.md): Cap'n Proto files and release package format.

## Safe Entry

Standalone mode must be protected by a secret HTTP path prefix:

```bash
CLANDES_SAFE_ENTRY=/s_8f3c2b9d4a7e6f10
```

With this configured, clients use a base URL like:

```text
http://host:8080/s_8f3c2b9d4a7e6f10
```

Bare `/v1/...` routes are not exposed.

Generate a safe entry with:

```bash
printf '/s_%s\n' "$(openssl rand -hex 16)"
```

## Cap'n Proto Schemas

Schemas are checked into [`schema/`](schema/) and are also attached to releases as:

```text
clandes-capnp-schemas-<version>.tar.gz
clandes-capnp-schemas-<version>.tar.gz.sha256
```

Use these schemas to generate clients for the RPC management and policy interfaces.

## Community

Telegram: [@clandes_dev](https://t.me/clandes_dev)
