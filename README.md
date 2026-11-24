# OpenCode development environment

Contains:

+ OpenCode 2.3
+ Ubuntu 26.04
+ Python 3.14 + pip
+ OpenJDK 25 + maven
+ Rust 1.93 + cargo
+ PHP 8.5 + composer
+ Go 1.27
+ Node.js 26 + npm
+ [postgres-dba-mcp](https://github.com/a-lafon/postgres-dba-mcp)
+ [ddgs](https://github.com/deedy5/ddgs)

## Build

```bash
docker image build -t opencode:latest .
```

## Run

See `docker-compose.yml`

## MCP

Add configuration into project `opencode.json`.

### postgres-dba-mcp

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

### ddgs

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

## Useful plugins and skills

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
