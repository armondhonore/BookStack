# Nexlayer — BookStack

<!-- nexlayer:meta version=1 analyzed=2026-06-26T19:50:11Z repo=https://github.com/armondhonore/BookStack branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
BookStack is an open-source, self-hosted wiki platform designed for creating and organizing documentation in a book-like hierarchy. It is built on the Laravel framework using PHP and MySQL.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| PHP | language | 8.x | docker-compose.yml, composer.json |
| Laravel | framework | not specified | artisan, composer.json |
| MySQL | database | 8.4 | docker-compose.yml |
| Node.js | build | 22-alpine | package.json, docker-compose.yml |
| TypeScript | language | 6.0 | package.json, tsconfig.json |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- app/ — Laravel core application logic
- bootstrap/ — Framework bootstrapper
- database/ — Database migrations and seeds
- public/ — Web server root and compiled assets
- resources/ — Raw SASS/JS assets and Blade templates
- routes/ — Application URL routing
- storage/ — Application logs and file uploads
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- SMTP Mail Server (MAIL_HOST)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- PHP 8.x
- Composer
- Node.js 22
- MySQL 8.4

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
APP_KEY=base64:randomstring
DB_HOST=127.0.0.1
DB_DATABASE=bookstack
DB_USERNAME=root
DB_PASSWORD=secret
APP_URL=http://localhost:8080
```

### Steps

1. `composer install` — Install PHP dependencies
2. `npm install` — Install frontend dependencies
3. `npm run build` — Compile CSS and JS assets
4. `php artisan key:generate` — Generate application encryption key
5. `php artisan migrate` — Run database migrations

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `APP_URL` | `"<% URL %>"` | plain |
| `app` | `DB_HOST` | `"${mysql:3306}"` | inter-pod |
| `app` | `DB_PORT` | `"3306"` | plain |
| `app` | `DB_CONNECTION` | `"mysql"` | plain |
| `mysql` | `MYSQL_ROOT_PASSWORD` | `"${MYSQL_ROOT_PASSWORD}"` | inter-pod |
| `mysql` | `MYSQL_DATABASE` | `"bookstack"` | plain |
| `mysql` | `MYSQL_USER` | `"bookstack"` | plain |
| `mysql` | `MYSQL_PASSWORD` | `"${MYSQL_PASSWORD}"` | inter-pod |

### nexlayer.yaml

```yaml
application:
  name: bookstack
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/bookstack:9f057b0-fix8"
      path: /
      servicePorts:
        - 80
      vars:
        APP_URL: "<% URL %>"
        DB_HOST: "${mysql:3306}"
        DB_PORT: "3306"
        DB_CONNECTION: "mysql"
    - name: mysql
      image: mirror.gcr.io/library/mysql:8.4
      path: /mysql
      servicePorts:
        - 3306
      vars:
        MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
        MYSQL_DATABASE: "bookstack"
        MYSQL_USER: "bookstack"
        MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| app | mirror.gcr.io/library/php:8.3-fpm-alpine | 80 | web |
| db | mirror.gcr.io/library/mysql:8.4 | 3306 | database |
| mailhog | mirror.gcr.io/library/mailhog/mailhog | 8025 | worker |

### Deployment notes

- The application connects to the database pod via db.pod:3306
- The application connects to the mail delivery pod via mailhog.pod:1025
- Static assets must be pre-compiled using the node build process before deploying to the app pod

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-26T20:39:04Z  
**Live URL:** https://relaxed-weasel-bookstack.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: bookstack
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/bookstack:9f057b0-fix8"
      path: /
      servicePorts:
        - 80
      vars:
        APP_URL: "<% URL %>"
        DB_HOST: "${mysql:3306}"
        DB_PORT: "3306"
        DB_CONNECTION: "mysql"
    - name: mysql
      image: mirror.gcr.io/library/mysql:8.4
      path: /mysql
      servicePorts:
        - 3306
      vars:
        MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
        MYSQL_DATABASE: "bookstack"
        MYSQL_USER: "bookstack"
        MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-26T19:50:11Z | analyzed | initial repo analysis |
| 2026-06-26T20:39:04Z | success | deployed https://relaxed-weasel-bookstack.cloud.nexlayer.ai |
<!-- nexlayer:end -->
