---
title:  "Dokku Release 0.25.0"
date:   2021-09-04 21:45:30 -0400
tags:
  - dokku
  - release
---

With the 0.25.x release of Dokku a few weeks ago, a folks may have questions as to why they would want to upgrade and how it would impact their workflows. We've cherry-picked a few more important changes, but feel free to go through the [release notes](https://github.com/dokku/dokku/releases/tag/v0.25.0) for more information.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Changes

### Make heroku-20/focal the default stack for herokuish builds

With the release of newer versions of Ubuntu, the heroku-18 stack (based on Ubuntu 18.04) was getting a bit long in the tooth. We've since switched to `heroku-20` as our default. Many apps will continue to work as before, though some with compiled dependencies may have issues. This may be fixed by either of the following:

- Clearing build cache, which will force a rebuild: `dokku repo:purge-cache $APP`
- Setting the stack to `heroku-18`: `dokku buildpacks:set-property $APP stack gliderlabs/herokuish:latest-18`

Users may also set the `stack` property globally by specifying `--global` instead of an app name.

### Drop web installer in favor of setup via cli

Dokku has had a Web installer for years. This installer has been useful for getting started - especially when setup via a cloud image on popular hosting providers - but has been an open security risk for those that forget that it exists.

Rather than try weird schemes to lock it down or notify users that it is still around, we've decided to remove it completely. It's usage is replaced by the following commands:

```shell
# usually your key is already available under the current user's `~/.ssh/authorized_keys` file
cat ~/.ssh/authorized_keys | dokku ssh-keys:add admin

# you can use any domain you already have access to, also takes an IP address
dokku domains:set-global dokku.me
```

We strive to make Dokku secure by default, and this is a step in that direction.

### Drop support for Ubuntu 16.04

While our debian packages are generic enough to use on any Debian-based operating system, we've dropped support for Ubuntu 16.04 as it reached the public End of Life in April of 2021. This allows us to spend more time testing on newer systems. We've also added initial support for Debian Bullseye (in 0.25.2) for those using Debian's latest release.

We will continue to add support for other operating systems as time goes on.

## New Features

### Add support for the formation key in `app.json`

Dokku has long had support for a `DOKKU_SCALE` file that tracked repo-specified scaling settings for apps. This was _also_ the name for a file on disk that held the scale contents. Code handling whether a user could scale or not was quite brittle.

Users may now specify a `formation` key in their `app.json` file. This is similar to heroku, and currently supports scale `quantity` on a per-process basis.

```json
{
  "formation": {
    "web": {
      "quantity": 1
    },
    "worker": {
      "quantity": 4
    }
  }
}
```

The goal here is to consolidate various app config stored in a variety of files in repo into one `app.json` file. We'll be following Heroku's specification around this file where possible, but will extend it where necessary - as we did with [Cron support in 0.23.x](/release/dokku-0.23.0).

See the [process management documentation](https://dokku.com/docs/processes/process-management/#manually-managing-process-scaling) for more information on how to use this in your apps.

### Add monorepo support

Some users may find a need to deploy an app several times with slightly different settings each time. This generally works by setting environment variables as necessary, but some things require changing which in-repo files are used. We've made changes across Dokku to respect changing the following:

- `appjson-path`:
    - description: Controls what the path is to the `app.json` file
    - command: `dokku app-json:set $APP appjson-path`
- `build-dir`:
    - description: Controls the root app directory for builds
    - command: `dokku builder:set $APP build-dir`
- `projecttoml-path`:
    - description: Controls the `project.toml` path used for Cloud Native Buildpack builds
    - command: `dokku builder-pack:set $APP projecttoml-path`
- `dockerfile-path`:
    - description: Controls the `Dockerfile` path for dockerfile-based builds
    - command: `dokku builder-dockerfile:set $APP dockerfile-path`
- `procfile-path`:
    - description: Controls the path to the `Procfile`
    - command: `dokku ps:set $APP procfile-path`

Feel free to file issues for any other files in use by Dokku that should be changed to allow better monorepo support.

### Implement the `registry` plugin

Users of the new `git:from-image` functionality [introduced in 0.24](/release/dokku-0.24.0) may have noticed missing support for authenticating against remote registries. This was added in the new [registry management plugin](https://dokku.com/docs/advanced-usage/registry-management/), and generally supports the same interface you'd see with `docker login`:

```shell
# hub.docker.com
dokku registry:login docker.io $USERNAME $PASSWORD

# password via stdin
echo "$PASSWORD" | dokku registry:login --password-stdin docker.io $USERNAME
```

Additionally, schedulers other than the `docker-local` scheduler require that the deployed image be available on a registry. This plugin can be used for upload images after the build process completes.

```shell
dokku registry:set node-js-app push-on-release true
```

Images will be pushed to Docker Hub by default. Users may specify an alternative registry by setting the `server` property:

```shell
dokku registry:set node-js-app server registry.digitalocean.com/
```

Users of the community [dokku-registry](https://github.com/dokku/dokku-registry) plugin should uninstall that plugin before upgrading Dokku, and then ensure that their apps are re-configured with the built-in plugin.

See the [registry management documentation](https://dokku.com/docs/advanced-usage/registry-management/) for more information on how to use the registry plugin.

### Revamp the `dokku run` command

The `dokku run` command was often misunderstood. Users assumed the containers would disappear after use, and there was no way to understand what containers were running via `dokku run`.

The new release automatically includes the `--rm` flag on containers created by `dokku run`. Users wishing to run detached containers should use the `dokku run:detached` command.

We also introduced the `run:list` command, which can be used to list all containers created by `dokku run` (by filtering on the `com.dokku.container-type=run` docker label). Users will be able to quickly see what is currently running. In the future, users may be able to enter those running containers via `run:enter`, and remove any errant ones via `run:destroy`.

Please note that implementation and semantics of `dokku run` are up to individual scheduler plugins.

### Routing to non-Dokku managed apps

In some cases, it may be necessary to route an app to an existing `$IP:$PORT` combination. This is particularly the case for internal admin tools or services that aren't run by Dokku but have a web ui that would benefit from being exposed by Dokku. This can be done by setting a value for `static-web-lister` network property and running a few other commands when creating an app.

```shell
# for a service listening on:
# - ip address: 127.0.0.1
# - port: 8080
# create the app
dokku apps:create local-app

# set the builder to the null builder, which does nothing
dokku builder:set local-app selected null

# set the scheduler to the null scheduler, which does nothing

# for dokku 0.25.x
dokku config:set local-app DOKKU_SCHEDULER=null

# for dokku 0.26+
dokku scheduler:set local-app selected null

# set the static-web-listener network property to the ip:port combination for your app.
dokku network:set local-app static-web-listener 127.0.0.1:8080

# set the port map as desired for the port specified in your static-web-listener
dokku proxy:ports-set local-app http:80:8080

# set the domains desired
dokku domains:set local-app local-app.dokku.me

# build the proxy config
dokku proxy:build-config local-app
```

The above takes advantage of new `null` builder and scheduler plugins that do nothing during the build or schedule phases.

This functionality can be used when trying to expose non-Dokku maintained services to the external world without requiring a deployed proxy. One nice side-effect is that this also means users can expose services with letsencrypt support.

## Upgrading

As with every upgrade, please see the [0.25.0 migration guide](https://dokku.com/docs/appendices/0.25.0-migration-guide/) for more information on upgrading to 0.25.0.

## The Next Minor Release

Our next release will continue on the [14 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
