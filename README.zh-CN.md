# OpenClandes 中文文档

OpenClandes 是 Clandes 的公开文档与协议仓库。

这个仓库只公开三类内容：

- 使用文档：如何部署、配置、注册账号、接入客户端
- 开发/集成文档：如何接入外部决策端、如何使用 RPC 协议
- Cap'n Proto RPC 协议文件：位于 [`schema/`](schema/)

这个仓库不公开 Clandes 服务端源代码，不包含 `bins/`、`crates/`、`Cargo.toml`、Dockerfile 或内部实现代码。

## Clandes 是什么

Clandes 是一个 AI 账号网关。客户端把 Anthropic 或 OpenAI/Codex 形态的 HTTP 请求发到 Clandes，Clandes 再把请求路由到已注册的上游账号。

当前公开的入站 HTTP API：

| 接口 | 用途 |
| --- | --- |
| `POST /v1/messages` | Anthropic Messages |
| `POST /v1/messages/count_tokens` | Anthropic token counting |
| `POST /v1/responses` | OpenAI Responses / Codex |
| `POST /v1/responses/compact` | Codex conversation compaction |
| `POST /v1/chat/completions` | OpenAI Chat Completions |

如果配置了安全入口，真实访问路径会变成：

```text
/{安全入口}/v1/messages
/{安全入口}/v1/responses
```

客户端通常只需要把 base URL 设置成：

```text
http://host:8080/{安全入口}
```

不要重复把 `/v1` 写进 base URL，除非你的客户端明确要求这样做。

## 快速部署

准备一个环境变量文件：

```bash
cat > .env.docker <<'EOF'
RPC_AUTH_TOKEN=replace-me-with-a-random-token
CLANDES_SAFE_ENTRY=/s_replace_with_random_hex
STANDALONE_MODE=1
ROUTE_STRATEGY=round_robin
RUST_LOG=info
EOF
```

生成随机值：

```bash
openssl rand -base64 32
printf '/s_%s\n' "$(openssl rand -hex 16)"
```

启动容器：

```bash
docker run -d --name clandes \
  --env-file .env.docker \
  -p 8080:8080 \
  -p 127.0.0.1:8082:8082 \
  -v clandes-data:/data \
  ghcr.io/shirasuki/clandes:0.1.5
```

推荐配置：

- HTTP 监听 `8080`
- RPC 只绑定到 `127.0.0.1:8082`
- 账号数据持久化到 Docker volume
- 设置 `RPC_AUTH_TOKEN`
- 自用模式必须设置 `CLANDES_SAFE_ENTRY`

## 注册账号

`clanctl` 可以直接在容器内执行。

查看账号：

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account list
```

添加 Claude OAuth 账号：

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account add
```

添加 Claude API key：

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" account add \
  --id claude-ak-1 \
  --type apikey \
  --api-key sk-ant-...
```

添加 Codex / ChatGPT OAuth 账号：

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" codex login
```

添加 OpenAI API key：

```bash
docker exec -it clandes clanctl --token "$RPC_AUTH_TOKEN" codex add-api-key \
  --id openai-ak-1 \
  --api-key sk-...
```

## 路由模式

### 自用模式

自用模式适合单机、自托管、自己管理账号池的部署。

```bash
STANDALONE_MODE=1
CLANDES_SAFE_ENTRY=/s_8f3c2b9d4a7e6f10
ROUTE_STRATEGY=round_robin
```

自用模式下，如果没有外部决策端连接，Clandes 会本地路由：

- 如果入站 credential 等于已注册的 `account_id`，使用这个账号
- 否则从对应 provider 的账号池里选择账号

因此自用模式必须配置高熵的 `CLANDES_SAFE_ENTRY`，不要暴露裸 `/v1/...`。

### 决策端模式

不设置 `STANDALONE_MODE`，或者设置为 false。

决策端模式下，HTTP 请求必须由连接到 RPC policy service 的外部决策端选择账号。没有决策端连接时，请求会被拒绝，不会自动退化成 `credential == account_id` 的本地路由。

这个模式适合需要计费、租户隔离、风控、配额、审计或自定义调度的场景。

## 安全入口

`CLANDES_SAFE_ENTRY` 是一个隐藏 HTTP `/v1/...` 路由的随机路径前缀。

示例：

```bash
CLANDES_SAFE_ENTRY=/s_8f3c2b9d4a7e6f10
```

客户端 base URL：

```text
http://host:8080/s_8f3c2b9d4a7e6f10
```

配置后，裸路径不会暴露：

```text
http://host:8080/v1/messages
```

不要使用容易猜到的入口，例如：

- `/api`
- `/admin`
- `/clandes`
- 用户名、项目名或常见单词

安全入口可能出现在反向代理 access log、浏览器历史、监控标签或 shell 历史里，应当像 bearer token 一样保护。

## 常用环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `API_LISTEN_ADDR` | `0.0.0.0:8080` | HTTP API 监听地址 |
| `RPC_LISTEN_ADDR` | `127.0.0.1:8082` | Cap'n Proto RPC 监听地址 |
| `RPC_AUTH_TOKEN` | 空 | RPC 鉴权 token；RPC 暴露到非可信网络时必须设置 |
| `CLANDES_SAFE_ENTRY` | 空 | HTTP 安全入口；`STANDALONE_MODE=1` 时必填 |
| `STANDALONE_MODE` | false | 开启无决策端时的本地路由 |
| `ROUTE_STRATEGY` | `random` | 自用模式账号选择策略：`random`、`round_robin`、`roundrobin` |
| `CLANDES_ACCOUNT_DB` | 默认路径 | redb 账号数据库路径；`0`、`off`、`none` 表示禁用持久化 |
| `OAUTH_BACKGROUND_REFRESH_INTERVAL_SECS` | `60` | OAuth 后台刷新扫描间隔；`0` 表示禁用 |
| `CLIENT_POOL_SIZE` | `4` | 每个账号的上游 HTTP client 池大小 |
| `SIGNATURE_CACHE_CAPACITY` | `131072` | billing signature 缓存容量 |
| `RUST_LOG` | 空 | tracing 日志过滤器，例如 `info` |

默认账号数据库路径按顺序选择：

- `$XDG_DATA_HOME/clandes/accounts.redb`
- `$HOME/.local/share/clandes/accounts.redb`
- `./clandes-data/accounts.redb`

调试相关变量：

| 变量 | 说明 |
| --- | --- |
| `CLANDES_DUMP_MESSAGES_DIR` | 把 Messages 请求/响应写入目录，可能包含敏感数据 |
| `CLANDES_DUMP_MESSAGES_JSON` | 通过 tracing 输出标准化后的 Messages JSON |
| `CLANDES_DUMP_UNREDACTED` | 禁用脱敏；只能用于本地调试 |
| `CLANDES_BLOCK_ANTHROPIC_UPSTREAM` | 阻止 Anthropic Messages 上游发送 |
| `TEST_PROXY_URL` | 代理测试使用的 SOCKS5 proxy URL |

## RPC 与外部决策端

Clandes 的管理接口和决策接口通过 Cap'n Proto RPC 暴露。

协议文件在 [`schema/`](schema/)：

| 文件 | 用途 |
| --- | --- |
| `clandes.capnp` | bootstrap 和 root service |
| `account.capnp` | 账号注册、更新、列表、删除 |
| `policy.capnp` | 外部决策端路由与事件流 |
| `proxy.capnp` | 代理探测 |
| `claude_auth.capnp` | Claude OAuth 登录和刷新 |
| `claude_query.capnp` | Claude profile、usage、role 查询 |
| `codex_auth.capnp` | ChatGPT/Codex OAuth 登录、刷新、撤销 |
| `codex_query.capnp` | Codex 账号 profile 查询 |
| `common.capnp` | 共享结构和枚举 |

RPC bootstrap 会接收一个 token 字符串。如果服务端配置了 `RPC_AUTH_TOKEN`，客户端必须传入同一个值。

如果 `RPC_AUTH_TOKEN` 为空，RPC 鉴权关闭。只应在可信本机接口上这样做。

### 决策端路由流程

决策端模式下，HTTP 请求不会在本地自动选账号。外部 policy client 连接到 policy service 后，会收到路由任务，任务包含：

- request ID
- 入站 API credential
- model
- endpoint
- user agent
- session ID
- client request ID

决策端可以返回：

- 目标 `account_id`
- 可选的 model / thinking 覆盖
- 拒绝状态和拒绝消息

如果没有 policy client 连接，并且没有开启自用模式，HTTP 请求会返回 no-route 错误。

### 事件流

policy service 也会发送事件给决策端：

- 请求完成或失败后的 usage report
- OAuth refresh 和账号生命周期事件
- SSE 响应中的 stream usage chunk

这些事件适合用于计费、监控、清理和审计。

## Cap'n Proto schema 包

schema 已提交在 [`schema/`](schema/)，release 里也会附带打包文件：

```text
clandes-capnp-schemas-<version>.tar.gz
clandes-capnp-schemas-<version>.tar.gz.sha256
```

下载后解压：

```bash
tar -xzf clandes-capnp-schemas-0.1.5.tar.gz -C ./schema
```

然后使用你所选语言/runtime 的 Cap'n Proto generator 生成 RPC 客户端代码。

## 安全建议

必须保护的内容：

- `RPC_AUTH_TOKEN`
- `CLANDES_SAFE_ENTRY`
- `.env` 文件
- 账号数据库
- OAuth access token / refresh token
- API key
- 代理账号密码
- message dump 目录

RPC 如果必须暴露到非本机环境，至少要设置：

```bash
RPC_AUTH_TOKEN=...
```

并尽量让 RPC 只监听本机：

```bash
RPC_LISTEN_ADDR=127.0.0.1:8082
```

不要在共享环境或生产环境开启未脱敏 dump：

```bash
CLANDES_DUMP_UNREDACTED=1
```

## 社区

Telegram: [@clandes_dev](https://t.me/clandes_dev)
