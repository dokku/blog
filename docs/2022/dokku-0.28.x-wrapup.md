---
title:  "Dokku 0.28.x Wrapup"
date:   2022-12-05 10:58:00 -0400
tags:
  - dokku
  - release
---

It's wrapup time! This post covers the important changes that occurred throughout the lifetime of the 0.28.x series.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Removals

### No more support for Centos 7, Debian 9, Fedora, OpenSuse

With the maturation of our [Docker-based deployment](https://dokku.com/docs/getting-started/install/docker/) offering, we've removed official support for these other operating systems.

Why would we do this? For Centos, Fedora, and OpenSuse, they were simply untested integrations that were half-baked into Dokku over the years. Worse, we only ever built a package for Centos, and never actually guaranteed support for the others.

As far as Debian 9 is concerned, the OS reached end-of-life in July of 2022, and it only makes sense to drop support for something unsupported upstream.

## Deprecations

### Ubuntu 18.04 is deprecated

Ubuntu 18.04 is now a deprecated installation target. The operating system will be considered EOL by Canonical in April 2023. Users are encouraged to upgrade to Ubuntu 22.04 or consider switching their installation method to the Docker-based installation method to avoid any disruption in usage.

## Additions

### The automatic init process can now be disabled

This change allows projects using s6 overlay - in particular [linxserver](https://linuxserver.io/) images - the ability to disable --init flag injection. 

Additionally, force-disable --init flag usage for all linuxserver images. [Linuxserver](https://linuxserver.io/) images uses S6, and there are enough of them that this makes sense to autodetect on behalf of users.

Users should be able to more easily deploy s6-based images, whether they are official Linuxserver ones or images they've built on their own :)

### New Proxy Implementations

As we've grown, the nginx plugin has seen a few warts. Notably, it doesn't tightly integrate with Docker, which sometimes causes requests to either route to the wrong container or fail when the container changes IP address. Additionally, our Letsencrypt integration on top of it is a bit of a hack.

As a result, we've decided to create official alternative proxy integrations to our existing nginx plugin. The first two are `caddy` and `traefik`, both of which boast healthy development processes and have great integrations with Docker-based deployment environments. In a future release, we also hope to add an official `haproxy` plugin, and may revisit our `nginx` integration as well.

Please note that none of this means we're dropping support for our existing `nginx` integration. Users should feel comfortable depending on nginx, switching only as needed.

#### An official caddy proxy implementation

This plugin uses a docker-compose based Caddy installation in conjunction with injected container labels to route requests. It only exposes the minimal necessary for routing traffic to docker containers. Users wishing to customize further labels may explore using the docker-options plugin to attach additional labels during the 'deploy' phase.

One big change is that requests are routed as soon as the container is running and passing [healthchecks](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#active-health-checks).

Checkout the official [caddy integration documentation here](https://dokku.com/docs/networking/proxies/caddy/)!

#### An official traefik proxy implementation

While Caddy is great, some folks may wish to pursue deeper, Traefik-based integration instead. Unlike Caddy, Traefik provides native integration with many schedulers, providing even deeper integration for your routing needs.

This plugin uses a docker-compose based Traefik installation in conjunction with injected container labels to route requests. It only exposes the minimal necessary for routing traffic to docker containers. Users wishing to customize further labels may explore using the docker-options plugin to attach additional labels during the 'deploy' phase.

Requests are routed as soon as the container is running and passing [healthchecks](https://doc.traefik.io/traefik/routing/services/#health-check).

Checkout the official [traefik integration documentation here](https://dokku.com/docs/networking/proxies/traefik/)!

### A builder for lambda functions

Dokku has always been a something of a generic workflow tool. Source code comes in, gets built into an artifact, and then can be scheduled.

With 0.28.x, we've introduced a new `builder-lambda` plugin. This plugin emulates the lambda build process, generating both a runnable docker image and a tarball that is compatible with AWS Lambda. We hope to bring an AWS Lambda-compatible scheduler to Dokku in the near future.

Checkout the official [builder-lambda documentation here](https://dokku.com/docs/deployment/builders/lambda/)!

### Add support for devcontainers on ARM64 instances

Lots of developers - including myself! - are moving to M1/M2 MacOS installations, and development of Dokku must continue. The 0.28.x series adds support for using VSCode Devcontainers on ARM64 instances, allowing development to continue unabated.

Truthfully, this is somewhat selfish as my main driver had to change - RIP my Intel Mac - but hopefully others contributing to Dokku also benefit :)

## Fixes

### Set core.bare=true on correct repository path

When deploying a project via `git:sync`, it was possible to get into a state where your repo was no longer able to have `git push` executed against it. This change fixes that, so folks can initialize apps via `git:sync` for the first time and then `git push` afterwards.

### Ignore https mappings when no ssl certificate exists

This fixes issues where users may somehow add an https mapping but are missing an ssl certificate, causing nginx to not load properly. We now ignore the mapping and warn users of the misconfiguration.

## Upgrading

As with every upgrade, please see the [0.28.0 migration guide](https://dokku.com/docs/appendices/0.28.0-migration-guide/) for more information on upgrading to 0.28.0.

## It's a wrap

Those were the major changes in 0.28.x. Our next post will cover 0.29.0!

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
