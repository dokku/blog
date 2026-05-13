---
title:  "Dokku Release 0.38.0"
date:   2026-04-30 14:35:00 -0400
tags:
  - dokku
  - release
---

The first release of the year is here! Here is a summary of what is new in [0.38.x](https://github.com/dokku/dokku/releases/tag/v0.38.0).

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Security fixes in 0.38.2

The [0.38.2](https://github.com/dokku/dokku/releases/tag/v0.38.2) patch release bundles four security fixes. All users on 0.38.x are encouraged to upgrade to 0.38.2 (or later) as soon as possible.

- [#8590](https://github.com/dokku/dokku/pull/8590): Restrict app names to prevent command injection.
- [#8591](https://github.com/dokku/dokku/pull/8591): Harden archive extraction against symlink traversal.
- [#8589](https://github.com/dokku/dokku/pull/8589): Enforce `0600` permissions on the `.netrc` credentials file.
- [#8588](https://github.com/dokku/dokku/pull/8588): Sanitize openresty include filenames to prevent eval injection.

Upgrade via the bootstrap script:

```shell
wget -NP . https://dokku.com/install/v0.38.2/bootstrap.sh
sudo DOKKU_TAG=v0.38.2 bash bootstrap.sh
```

## Breaking changes in 0.38.x

### Environment variables migrated to plugin properties

A number of `DOKKU_*` config environment variables have been replaced with properly-namespaced plugin properties. Existing values are migrated automatically the first time `dokku` runs after the upgrade, and the original config variable is unset. No manual action is required at upgrade time, but setting the deprecated env vars via `dokku config:set` will no longer have any effect going forward.

The most common mappings:

| Deprecated env var | Replacement command |
|---|---|
| `DOKKU_APP_PROXY_TYPE` | `dokku proxy:set <app> type <value>` |
| `DOKKU_APP_RESTORE` | `dokku ps:set <app> restore <true\|false>` |
| `DOKKU_APP_SHELL` | `dokku scheduler:set <app> shell <value>` |
| `DOKKU_CHECKS_DISABLED` | `dokku checks:disable <app> [proctypes]` |
| `DOKKU_CHECKS_ENABLED` | `dokku checks:enable <app> [proctypes]` |
| `DOKKU_DISABLE_PROXY` | `dokku proxy:disable <app>` / `dokku proxy:enable <app>` |
| `DOKKU_DOCKERFILE_START_CMD` | `dokku ps:set <app> dockerfile-start-cmd <value>` |
| `DOKKU_PROXY_PORT` | `dokku proxy:set <app> proxy-port <value>` |
| `DOKKU_PROXY_SSL_PORT` | `dokku proxy:set <app> proxy-ssl-port <value>` |
| `DOKKU_SKIP_DEPLOY` | `dokku ps:set <app> skip-deploy <true\|false>` |
| `DOKKU_START_CMD` | `dokku ps:set <app> start-cmd <value>` |

`DOKKU_PARALLEL_ARGUMENTS` is removed entirely with no replacement. `DOKKU_SKIP_CLEANUP` continues to be honored when set in `/etc/environment` or `~dokku/.dokkurc/*` so that bootstrap-time configuration keeps working, but the new `builder skip-cleanup` property is the canonical interface and takes precedence when set.

The [0.38.0 migration guide](https://dokku.com/docs/appendices/0.38.0-migration-guide/) has the complete list.

### ENV file paths consolidated

The path on disk to both the global `ENV` file and per-app `ENV` files have been moved to a consolidated config path. Users should reference environment variables via the provided plugin triggers rather than directly sourcing the `ENV` files. Existing files are left untouched and will be removed on the subsequent Dokku install.

### Default nginx behavior for apps without running web processes

Dokku now generates a minimal nginx configuration for apps without running `web` processes - undeployed apps, apps with no `web` process type, or apps with stopped web processes. The generated configuration returns a `502 Bad Gateway` response, ensuring the app's domain resolves and monitoring tools can detect non-200 status codes. The configuration is automatically replaced with the full proxy configuration once the app is deployed with running `web` processes.

Users with custom `nginx.conf.sigil` templates that reference `DOKKU_APP_WEB_LISTENERS` should be aware that this variable may now be empty when the template is rendered. Custom templates should handle this case gracefully, for example by using a conditional to serve an error page instead of proxying:

```
location / {
{{ if $.DOKKU_APP_WEB_LISTENERS }}
  proxy_pass  http://{{ $.APP }}-{{ $upstream_port }};
{{ else }}
  return 502;
{{ end }}
}
```

### Catch-all default site on fresh apt installs

Fresh apt installs now ship a catch-all default site at `/etc/nginx/conf.d/00-default-vhost.conf` that rejects requests with unknown Host headers using `ssl_reject_handshake on` (HTTPS) and `return 444` (HTTP). This replaces the manual workaround previously documented in the nginx docs. The behavior can be opted out at install time via the `dokku/install_default_site` debconf prompt.

On nginx older than 1.19.4 (such as Debian Bullseye's nginx 1.18.0), the postinst installs an HTTP-only variant of the catch-all that omits the SSL listener and `ssl_reject_handshake`, since that directive is unsupported on those versions.

During a fresh apt install, the upstream nginx default vhost files (`/etc/nginx/sites-enabled/default`, `/etc/nginx/sites-available/default`, and `/etc/nginx/conf.d/default.conf`) are renamed to `${path}.dokku-disabled` rather than deleted, so operators with local customizations can recover them by inspecting the `.dokku-disabled` siblings. Upgrade-in-place installs do not touch any existing nginx files.

With the new catch-all installed on nginx 1.19.4+, an HTTPS request to a hostname that matches a configured Dokku app but where the app has no TLS certificate configured will have its TLS handshake rejected by the catch-all. Previously, nginx fell through to the lexicographically first port-443 server block and presented that block's certificate, producing a cert-mismatch error on the client. The new behavior is a correctness improvement, but operators who deliberately relied on the old fall-through certificate need to either configure a certificate for the target app or remove the catch-all. Existing apps that already have certificates configured are unaffected.

### `SIGTERM` sent immediately to old containers on deploy

The `docker-local` scheduler now sends `SIGTERM` to old containers immediately after a successful deploy, rather than waiting `wait-to-retire` seconds before signaling. This matches Heroku's graceful-shutdown contract and lets applications begin draining in-flight work as soon as proxy traffic switches. The `wait-to-retire` grace period and `stop-timeout-seconds` hard-stop continue to apply as before.

### Storage plugin redesign

The storage plugin now treats persistent volumes as named, scheduler-aware first-class resources via `storage:create`, `storage:mount`, `storage:set`, and `storage:destroy`. The legacy `storage:mount <app> <host>:<container>` colon form continues to work on docker-local apps but is deprecated; on k3s apps it is rejected outright.

```shell
dokku storage:create my-data
dokku storage:mount my-app my-data:/data
```

Existing colon-form mounts are migrated automatically the first time the new storage plugin runs - they appear as `legacy-<hash>` entries in `storage:list-entries`. Storage entry names must now be DNS-1123 labels of 45 characters or less so they can be used verbatim as Helm release and Kubernetes resource names. The `storage:ensure-directory` command keeps working but now emits a deprecation warning; prefer `storage:create <name> [<path>]` going forward.

### `scheduler-k3s` env config and pull secret split into stable helm releases

The `scheduler-k3s` plugin now manages env config and the Dokku-generated image pull Secret as their own helm releases with stable names (`config-{app}` and `pull-secret-{app}`) rather than bundling them into the app helm chart with a per-deploy timestamp suffix. This fixes two bugs: a helm rollback of the app chart no longer deletes Secrets that older ReplicaSets still reference, and the Deployment's `imagePullSecrets` list no longer accumulates references to nonexistent Secrets across deploys.

The next deploy of an app switches the Deployment's `envFrom` and `imagePullSecrets` references to the stable names and prunes any leaked entries. App rename now also uninstalls the old `tls-{app}`, `config-{app}`, and `pull-secret-{app}` releases under the previous app name; the new name's releases are recreated on the next deploy or certs sync.

## New in 0.38.x

### Builds plugin migrated to Go with per-build records

The builds plugin has been rewritten in Go and now tracks per-build records. Dokku now retains a history of each build performed against an app, with metadata about the build available via the plugin. The new `builds:output` command retrieves build logs for a tracked build, making post-mortem debugging of failed builds much easier without having to scroll through the deploy log.

### Buildpacks via `app.json`

Users can now specify CNB and herokuish buildpacks declaratively in `app.json` rather than via a separate `.buildpacks` file or environment variable. This brings buildpack configuration in line with the rest of the build-time configuration Dokku already reads from `app.json`.

### Live-restore enabled by default on fresh install

Dokku now configures the Docker daemon with `live-restore` enabled on fresh apt installs. This keeps running containers up across daemon restarts and upgrades, removing a common source of unexpected app downtime during routine Docker maintenance. Existing installs are not modified.

### Resource limits on the build container

Users can now apply resource limits - memory and CPU - to the container Dokku spawns to build an app. This is particularly useful on shared or low-memory hosts where a single runaway build can starve running apps.

### Per-process docker-options

The `docker-options` plugin can now scope options to specific Procfile process types rather than the app as a whole. Users who want to apply, say, a particular memory limit only to a `worker` process type can do so without affecting the `web` process.

### `app.json` `env` honored on post-create

The `env` key in `app.json` is now honored during the `post-create` phase, so apps created from a remote image or built from a repository that contains an `app.json` will receive their declared environment variables automatically.

### `git:auth-status` command

A new `git:auth-status` command checks whether a given remote matches a configured netrc entry, without exposing the credential itself. This is handy for verifying that `git:auth` was configured correctly without having to attempt a deploy.

### `--global` on all `:report` subcommands

All `:report` subcommands now accept the `--global` flag, which scopes the report to globally-configured properties. The flag composes with `--format json`, so a JSON report of global properties can be obtained via, for example:

```shell
dokku scheduler:report --global --format json
```

Previously, combining `--global` with `--format json` was rejected with an "info flag" error, and `--global` on its own was treated as an unknown flag.

### Pre-validation of custom `nginx.conf.sigil`

Custom `nginx.conf.sigil` templates are now validated during `core-post-extract`, catching template errors before the deploy proceeds rather than at proxy-rebuild time. Users with broken templates will see a clear error early in the deploy rather than a partial outage on rebuild.

### k3s chart upgrades

The bundled charts for k3s users have been refreshed:

- vector from 0.42.0 to 0.52.0
- ingress-nginx from 4.10.0 to 4.15.1
- keda to 2.19.0, and keda-add-ons-http to 0.12.2

## Bug Fixes

### Preserve all domains when renaming an app

Previously, renaming an app could result in the domain set being partially lost. Dokku now correctly preserves all configured domains across a rename.

### Skip retiring images still in use

The `dokku-retire` cron timer would previously log `Image ... has running containers, skipping rm` on every run when a `ps:rebuild` against an image-based deploy produced an identical-SHA image. Dokku no longer queues an image for retirement when another running container of the same app still uses it. Stuck entries from prior versions are pruned automatically on the next `ps:retire` run.

### Retire orphaned containers when scaling down

Scaling an app down now correctly retires orphaned containers that were left behind by the previous scale.

### CNB `launcher` entrypoint for `dokku run` / `cron:run`

CNB images launched via `dokku run` and `cron:run` now correctly use the CNB `launcher` entrypoint, fixing one-off commands and cron tasks for buildpack apps that previously failed to start.

### KEDA fallback only emitted when needed

The `scheduler-k3s` plugin now emits the KEDA fallback configuration only when a non-cpu/memory trigger exists, avoiding spurious configuration for the common case.

## Upgrading

As with every upgrade, please see the [0.38.0 migration guide](https://dokku.com/docs/appendices/0.38.0-migration-guide/) for more information on upgrading to 0.38.0.

## Future Plans

### The Next Minor Release

Our next minor release will be 0.39.0, continuing the work on the [outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

### Dokku Pro

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

Interested in purchasing [Dokku Pro](https://pro.dokku.com/)? Dokku Pro is currently provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
