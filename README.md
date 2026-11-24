# OpenCode development environment

Contains:

+ OpenCode 2.4
+ Ubuntu 26.04
+ Python 3.14 + pip
+ OpenJDK 25 + maven
+ Rust 1.93 + cargo
+ PHP 8.5 + composer
+ Go 1.27
+ Node.js 26 + npm
+ [postgres-dba-mcp](https://github.com/a-lafon/postgres-dba-mcp)
+ [ddgs](https://github.com/deedy5/ddgs)
+ [dbhub](https://github.com/bytebase/dbhub)
+ [Graphify](https://github.com/Graphify-Labs/graphify)

## Build

```bash
docker image build \
  --build-arg OPENCODE_UID=$(id -u) \
  --build-arg OPENCODE_GID=$(id -g) \
  -t opencode:latest \
  .
```

## Run

Copy `docker-compose.yml`

```bash
mkdir -m 0777 data
docker compose up -d
```

Use TUI: `docker exec -it opencode opencode`

Use WebUI: `docker exec -it opencode opencode pair` And open link.

## Plugins and skills

### [opencode-mem](https://github.com/tickernelz/opencode-mem)

Installation. Add plugin to `~/.config/opencode/opencode.json`:

```json
  "plugins": ["opencode-mem@2.43.0"]
```

Configuration. Change defaults in `~/.config/opencode/opencode-mem.jsonc`:

```json
"embeddingModel": "Xenova/bge-m3", //for multi-language support

"opencodeProvider": "ollama", //or other model provider configured in OpenCode
"opencodeModel": "inherit", //use current OpenCode model

"autoCaptureEnabled": true,
"autoCaptureLanguage": "auto",
```

Memory explorer will be available at http://localhost:4747

### [plannotator](https://github.com/backnotprop/plannotator)

Installation:

```bash
curl -fsSL https://plannotator.ai/install.sh | bash
```

Configuration. Add plugin to `~/.config/opencode/opencode.json`:

```json
"plugins": [
    {
        "package": "@plannotator/opencode@latest",
        "options": {
            "workflow": "plan-agent",
            "planningAgents": ["plan"]
        }
    }
]
```

Environment. To use as remote service:

```bash
PLANNOTATOR_REMOTE: "1"
PLANNOTATOR_URL_HOST: "localhost"
PLANNOTATOR_PORT: "19432"
PLANNOTATOR_BIN: "/home/opencode/.local/bin/plannotator"
```

Plannotator will be available at http://localhost:19432

### [find-skills](https://github.com/vercel-labs/skills)

A skill to search and install other skills.

Installation:

```bash
#in current project
npx skills add https://github.com/vercel-labs/skills --skill find-skills

#globally
npx skills add https://github.com/vercel-labs/skills --skill find-skills --agent opencode -g
```

### [Graphify](https://github.com/Graphify-Labs/graphify)

Install globally:

```bash
graphify install --platform opencode
```

Install in project directory:

```bash
graphify install --project --platform opencode
```

In project opened at OpenCode:

```plain
/graphify .
```

## Skill libraries

+ [Skills](https://www.skills.sh/) - skills registry
+ [github/awesome-copilot](https://github.com/github/awesome-copilot)
+ [obra/superpowers](https://github.com/obra/superpowers)
+ [affaan-m/ECC](https://github.com/affaan-m/ECC)
+ [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang)
+ [nat/oc-mwg](https://code.doublebyte.ru/nat/oc-modern-web-guidance)

## MCP

Add configuration into project `opencode.json`.

### [postgres-dba-mcp](https://github.com/a-lafon/postgres-dba-mcp)

```json
"mcp": {
    "servers": {
      "pg": {
        "type": "local",
        "command": ["postgres-dba-mcp"],
        "environment": {
          "DATABASE_URI": "postgres://username:password@localhost:5432/dbname"
        },
      },
    },
  },
```

### [ddgs](https://github.com/deedy5/ddgs)

```json
"mcp": {
    "servers": {
      "ddgs": {
        "type": "local",
        "command": ["ddgs", "mcp"],
      },
    },
  },
```

### [dbhub](https://github.com/bytebase/dbhub)

```json
"mcp": {
    "servers": {
      "dbhub": {
        "type": "local",
        "command": [
          "dbhub", 
          "--transport", "http",
          "--port", "9876",
          "--dsn", "postgres://username:password@localhost:5432/dbname"
        ],
      },
    },
  },
```
