---
title:  "Dokku Release 0.30.0"
date:   2023-03-14 01:07:00 -0400
tags:
  - dokku
  - release
---

The first minor release of the year is here! Here is a summary of what is new in [0.30.x](https://github.com/dokku/dokku/releases/tag/v0.30.0).

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Removals in 0.30.x

The following functionality has long been deprecated and is now removed:

- The `logs:failed` command now requires specifying an app (or the `--all` flag).
- Builder-specific post-release hooks are removed in favor of `post-release-builder`, which takes the builder as an argument.
- The global `--detached` flag used for `dokku run` is now supersceded by `dokku run:detached`.
- Support for the `DOKKU_SCALE` file is removed. Users should migrate immediately to `app.json`.
    - Anyone upgrading from very old Dokku versions _or_ using the `DOKKU_SCALE` command to specify scale will see issues. Please upgrade to Dokku `0.29.x` and rebuild your apps once prior to upgrading to Dokku `0.30.x`.
- SPDY support has been removed in favor of http2.
    - Anyone using a custom template should remove references to SPDY or a future release will fail to build.

We also removed a ton of deprecated commands and functions across dokku in [#5659](https://github.com/dokku/dokku/pull/5659).

## Changes in 0.30.x

### EOL of Ubuntu 18.04 support

With upstream dropping LTS support, Ubuntu 18.04 support in Dokku is EOL. Users are _heavily_ encouraged to upgrade their operating systems to Ubuntu 20.04 or Ubuntu 22.04, either via an upgrade or fresh install. The next release of Dokku will stop releasing for Ubuntu 18.04 and packages will be removed in the future.

Please note that while our existing packages _may_ continue to run on Ubuntu 18.04, issues for those running on 18.04 may be summarily closed.

Finally, Herokuish will also shortly drop Ubuntu 18.04 releases. Users are heavily encouraged to upgrade their apps to newer stacks, as those apps may fail to build for a variety of reasons.

### app.json extraction moved from image to repository

In 0.29.x, we moved file extraction for various supporting files from the built image to the app source. This change now also applies to `app.json`. This was done in order to standardize how mono-repo codebases were built.

With 0.30.x, we now extract `app.json` from the repository source code where possible. This allows our monorepo codebase handling to act the same everywhere and also speeds up app builds.

## New in 0.30.x

#### An official haproxy proxy implementation

This plugin uses a docker-compose based Haproxy installation in conjunction with injected container labels to route requests. It only exposes the minimal necessary for routing traffic to docker containers. Users wishing to customize further labels may explore using the docker-options plugin to attach additional labels during the 'deploy' phase.

Big thanks to [@byjg](https://github.com/byjg) for their work on [EasyHAProxy](https://github.com/byjg/docker-easy-haproxy/)

Checkout the official [haproxy integration documentation here](https://dokku.com/docs/networking/proxies/haproxy/)!

### Simplified image deployment via `git:load-image`

Similar to `git:load-image` - and using the same internal infrastructure to manage history - there is a new `git:load-image` command. This new command supports deploying the output of `docker image save $IMAGE_NAME` on stdin, keeping git history with every deploy.

The `git:load-image` command is meant to be used in cases where the deployment model is to deploy from a built docker image in CI. This is useful when users do not have an intermediate docker registry available from which they can deploy.

See the [git documentation](https://dokku.com/docs/deployment/methods/git/#initializing-an-app-repository-from-a-remote-image-without-a-registry) for further details.

### Interacting with multiple dokku remotes via the official client

In some cases, users may deploy a given repository to multiple Dokku apps. This is especially useful when deploying to pre-production environments or using review apps. The official client now supports a series of `remote` subcommands that allow users to manage remotes for a local repository.

See the [remote client documentation](https://dokku.com/docs/deployment/remote-commands/#specifying-a-remote) for further details.

## Bug Fixes

### Nginx proxy rebuilds early to avoid downtime

In a previous release, we moved the `web` process to be deployed first. This allowed folks to quickly see errors on their mainline process, vs seeing those near the end. The end result, however, made it so that apps with large numbers of process types had downtime as the old `web` containers were removed after a minute if the app also used `nginx` as it's proxy layer. Users of other proxy implementations - such as Caddy, Haproxy, and Traefik - are not affected by this bug.

We now trigger an early rebuild of the nginx config for users utilizing the `nginx` proxy implementation. Concerned users should switch to other proxy implementations to be completely unaffected by this change.

Note that a future release of Dokku will also provide an optional nginx-proxy layer based on labels similar to our other proxy implementations. This will avoid long-standing downtime issues and hopefully allow us to be more flexible in how applications can be proxied. See the [nginx-docker-proxy](https://github.com/dokku/nginx-docker-proxy) project for more details.

### Avoid reinstalling plugins in the provided Dokku docker image

We now no longer attempt to reinstall plugins that already exist. This fixes issues for users that specify plugins via a `plugin-list` versus installing directly to the docker image via a custom Dockerfile.

### Fix pack entrypoint support

A recent change in CNB's pack utility changed how processes were launched, causing any process to fail to start. We now specify a custom entrypoint to fix this issue. Users of CNB can get back to building their apps!

## Upgrading

As with every upgrade, please see the [0.30.0 migration guide](https://dokku.com/docs/appendices/0.30.0-migration-guide/) for more information on upgrading to 0.30.0.

## Dokku Pro

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

Interested in purchasing [Dokku Pro](https://pro.dokku.com/)? Dokku Pro is currently provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

## The Next Minor Release

Our next release will continue on the [7 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
