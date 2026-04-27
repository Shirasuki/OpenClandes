# Usage Guide

This guide is for operators running the published Clandes image.

## 1. Prepare Configuration

Create an env file:

```bash
cat > .env.docker <<'EOF'
RPC_AUTH_TOKEN=replace-me-with-a-random-token
CLANDES_SAFE_ENTRY=/s_replace_with_random_hex
STANDALONE_MODE=1
ROUTE_STRATEGY=round_robin
RUST_LOG=info
EOF
```

Generate strong values:

```bash
openssl rand -base64 32
printf '/s_%s\n' "$(openssl rand -hex 16)"
```

## 2. Run the Container

Use the published image for the release you want to run:

```bash
docker run -d --name clandes \
  --env-file .env.docker \
  -p 8080:8080 \
  -p 127.0.0.1:8082:8082 \
  -v clandes-data:/data \
  ghcr.io/shirasuki/clandes:0.1.5
```

Recommended defaults:

- expose HTTP on `8080`
- bind RPC to `127.0.0.1:8082`
- persist account data in a Docker volume
- set `RPC_AUTH_TOKEN`
- set `CLANDES_SAFE_ENTRY` when using standalone mode

## 3. Register Accounts

Run `clanctl` inside the container:

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account list
```

Claude OAuth:

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account add
```

Claude API key:

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account add \
  --id claude-ak-1 \
  --type apikey \
  --api-key sk-ant-...
```

Codex / ChatGPT OAuth:

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" codex login
```

OpenAI API key:

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" codex add-api-key \
  --id openai-ak-1 \
  --api-key sk-...
```

## 4. Configure Clients

If your safe entry is:

```text
/s_8f3c2b9d4a7e6f10
```

then set the client base URL to:

```text
http://host:8080/s_8f3c2b9d4a7e6f10
```

Do not include `/v1` in the base URL unless your client explicitly expects that.

## 5. Routing Modes

### Standalone Mode

```bash
STANDALONE_MODE=1
CLANDES_SAFE_ENTRY=/s_8f3c2b9d4a7e6f10
ROUTE_STRATEGY=round_robin
```

When no decision service is connected, Clandes routes locally:

- if inbound credential equals a registered `account_id`, use that account
- otherwise pick an account from the matching provider pool

### Decision Service Mode

Leave `STANDALONE_MODE` unset or false.

HTTP requests must be routed by an external policy client connected to the RPC policy service. If no decision service is connected, requests are rejected.
