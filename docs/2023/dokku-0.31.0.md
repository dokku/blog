---
title:  "Dokku Release 0.31.0"
date:   2023-08-20 01:07:00 -0400
tags:
  - dokku
  - release
---

The second release of the year is here! Here is a summary of what is new in [0.31.x](https://github.com/dokku/dokku/releases/tag/v0.31.0).

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Deprecations

To start, there are a few features that are now deprecated in Dokku.

### ARM (not ARM64!) support is deprecated

Our build process around ARM is fairly flaky - breaking CI more often than not - and the resulting docker image/debian packages are not actually tested. As a result, we're going to remove support for the platform in the next release, and recommend users upgrade their operating systems to ARM64 where possible.

### Deprecation of the CHECKS file

This file is now deprecated in favor of the new healthchecks functionality in `app.json` - more on that later - and users should begin migrating today. The [docker-container-healthchecker](https://github.com/dokku/docker-container-healthchecker) tool can be used to convert a CHECKS file into the correct format for `app.json` usage. We expect to remove `CHECKS` support in a future release (likely 0.32.x).

### `proxy:ports-*` commands are deprecated

The `proxy:ports-*` commands are deprecated in favor of the new `ports` plugin - more on that later - users should adjust their workflows appropriately. The deprecation is occuring it was quite common for users to set port mappings incorrectly via `proxy:set`, thus breaking routing. Rather than keep the old commands around, we're going to nix it completely.

## Changes in 0.31.x

### heroku-22 is the new default

Dokku now tracks Ubuntu 22.04 for it's default builders. What does this mean?

- Herokuish builds are now based on `heroku-22`. Upgrading herokuish will _only_ pull that image now, vs one for each supported herokuish base image, thus reducing disk utilization.
- Cloud Native Buildpack builds now use the `heroku/builder:22` base builder. This is heroku's native CNB builder, and does not provide any shims for old buildpacks.

Users can still switch their base images via the command appropriate for their builder :)

### Herokuish builds now use volumes for cache

Previously, Herokuish builds would mount a directory on disk for build-time file caching. This worked mostly fine, but was an issue for a few reasons:

- The build cache was stored in the app's git directory, mucking up the usage of that folder. One of the goals for a 1.0 release is to remove anything that doesn't belong in that folder so we can have a better backup strategy.
- Folder permissions for the build cache effectively broke deploys when SELinux is enabled.
- Build cache could not be mounted properly in remote development environments such as Github Codespaces.

Dokku now uses a docker volume for herokuish build cache - similar to how Cloud Native Buildpacks treat cache - which greatly simplifies cache management.

## New in 0.30.x

#### An official openresty proxy implementation

This plugin uses a docker-compose based OpenResty installation in conjunction with injected container labels to route requests. It supports all properties supported by the nginx plugin, and includes built-in Letsencrypt support. Over time, we intend to make further improvements to this plugin and place the nginx plugin in a general maintenance mode. Users are encouraged to try out the OpenResty plugin to see if it meets their needs.

Big thanks to [OrcaScan](https://orcascan.com/) for sponsoring the work on [OpenResty](https://github.com/dokku/openresty-docker-proxy)!

Checkout the official [openresty integration documentation here](https://dokku.com/docs/networking/proxies/openresty/).

### Improved healthchecking support via `app.json`

The pre-existing healthcheck support in Dokku was fairly limited:

- Only web processes could be healthchecked
- Only http checks were supported (via curl)
- Configuring default uptime checks could only be done for an entire app, and not on a per-process basis
- Customizations to the http checks (such as extra headers) were impossible

All of these - and more - are solved by the new `healthchecks` support in the `app.json` file. Users can now specify one or more customized uptime checks, arbitrary command checks, as well as http checks (with more functionality!) for any process type.

```json
{
  "healthchecks": {
    "web": [
        {
            "type":        "startup",
            "name":        "web check",
            "description": "Checking if the app responds to the /health/ready endpoint",
            "path":        "/health/ready",
            "attempts": 3
        }
    ],
    "worker": [
        {
            "type":        "startup",
            "name":        "uptime check",
            "description": "Checking if the container is up for at least 10 seconds",
            "uptime":      10
        },
        {
            "type":        "startup",
            "name":        "command check",
            "description": "Checking if a command in the container runs as expected",
            "timeout":     5,
            "attempts":    5,
            "wait":        10,
            "command":     ["/app/script.sh"]
        }
    ]
}
```

!!! note

    Support for individual healthcheck properties is provided by individual schedulers, and not guaranteed to work the same across all schedulers. In particular, only the `docker-local` scheduler supports content checks for http requests.

Dokku will convert all `CHECKS` files into the `app.json` format until support for that file format is removed, and users can use the [docker-container-healthchecker](https://github.com/dokku/docker-container-healthchecker) tool to migrate to the new format.

While we only support `startup` checks - checks that happen during container start at deploy time - in the future, Dokku will also support readiness and liveness checks in the future for it's `docker-local` scheduler.

See the [zero downtime deploy checks documentation](https://dokku.com/docs/deployment/zero-downtime-deploys/#customizing-checks) for further details.

### Dokku Cron Improvements

For the docker-local scheduler, the crontab generation has been sped up tremendously. Deploys on installations with many apps should be much quicker as cron tasks for each app are generated in parallel vs serially as had been the case.

The `cron:list` command now has json output via the `--format json` option. This can help those integrating Dokku with other systems - such as Ansible modules.

Finally, cron tasks can now be executed on the fly via the `cron:run` command. This takes a cron-id - retrievable from the `cron:list` command - and happens inline by default. They can also be invoked in a detached manner, allowing cron tasks to be run by dispatch.

See the [cron documentation](https://dokku.com/docs/processes/scheduled-cron-tasks/) for further details.

### Environment variables are available for use with Dockerfile-based builds

Previously, a user wanting to use an environment variable during a build would have to specify the environment variable twice - once for run-time via `config:set` and once for build-time via `docker-options:add`. This was error prone as it was easy to fat finger a value, allowed for configuration drift, and made it more annoying to paste the output of `dokku report` for an app.

Dokku now automatically exports all environment variables during Dockerfile build. Users can simply specify `--build-arg SOME_ENV_VAR` docker option to pull in the desired environment variable.

See the [dockerfile builder documentation](https://dokku.com/docs/deployment/builders/dockerfiles/) for further details.

### Multi-network apps

Dokku has long had support for attaching apps to networks at different phases of an app lifecycle, but could only ever use a single network for each phase. This works well enough for simple architectures, but folks wanting more isolation between applications and datastores might want to place each in a different network and then join them as desired for inter-service communication.

Dokku now supports specifying multiple, comma-separated networks at each phase. Users can enjoy network isolation support and more easily deploy advanced topologies with the `docker-local` scheduler, allowing them to mimic what might be the case in production.

See the [network documentation](https://dokku.com/docs/networking/network/) for further details.

### More robust port handling via the new `ports` plugin

Dokku's port management has long been confusing:

- Several different environment variables controlling how ports are managed
- Port mappings could be overwritten by Dokku on deploy
- Responsibility for port handling was held by several different plugins
- The commands were hidden under the proxy plugin

Dokku 0.31.x introduces a new `ports` plugin, reducing a ton of complexity around how port mappings are managed. The new plugin centralizes a lot of the port management code, resulting in a removal of a few port-related network triggers, some environment variables, and more.

Additionally, Dokku now has "detected" port mappings that are fetched on a per-build basis. Users can override the port mapping as necessary, and Dokku will respect any overrides - or allow you to go back to the detected defaults! This makes it easy to ignore ports that are `EXPOSEd` in a Dockerfile or even use an alternate mapping for buildpack deploys.

The new ports plugin fixes several long-standing issues in port management in Dokku, and hopefully simplifies port interactions for all of our users.

See the [port management documentation](https://dokku.com/docs/networking/port-management/) for further details.

## Bug Fixes

### Server restarts do not start all proxy implementations

Dokku previously started a container for each proxy implementation, even when not in use. These are now properly tracked, and users will not see Dokku start the containers unless the user has explicitely run the `:start` subcommand.

### The `source-image` git property is now cleared when changing deployment methods

Previously, this property was left alone, resulting in Dokku not respecting the new source for extracting files for use in the deploy (such as `app.json`). Dokku will now properly handle this when the deployment method changes (such as when going from image-based to git push), greatly simplifying the process for our users who are experimenting with Dokku.

### Traefik integration now runs correctly when running on ARM64

Previously, users on ARM64 machines would not be able to enable traefik's letsencrypt integration due to a docker bug in file mounting. This is now fixed across all platforms - simply run `traefik:stop` and `traefik:start`.

## Future Plans

### Short-term project re-prioritization

With the release of Dokku 0.31.0, we've fixed a number of long-standing issues while also implementing a ton of great new features. While development isn't stopping, now is the time to refocus the project a bit for a few reasons:

- Dokku Pro - which I myself use for managing my own servers - hasn't had a release in quite some time, and there are a number of features built in Dokku that can now be better exposed in Dokku Pro.
- There are a number of open issues in official plugins that have thus been ignored. This has been an annoyance for more than a few users, and greatly diminishes the quality of the overall project.
- Dokku now has a ton of features but the Kubernetes and Nomad plugins implement but a fraction of them - missing are cron support, better healthchecks, and much more.
- Issues blocking a 1.0 release haven't decreased drastically over the past few years. Dokku itself is rock-solid, but a 1.0 label will ease anxieties for users upgrading Dokku.
- On a personal note, I've taken a job at [Porter](https://www.porter.run/), which offers a best-in-class experience around managing a highly-scalable PaaS on your own cloud provider. This will provide me an opportunity to take my learnings from building the best-in-class single-server PaaS to teams and companies that need a rock-solid platform that scales as they scale.

With all of the above in mind, the next few months will be spent on enhancing Dokku Pro, implementing long-desired functionality in the official plugins, burning through 1.0 blockers, and bringing the Kubernetes and Nomad scheduler plugins to parity with the built-in docker-local scheduler.

Is Dokku going away? No. Development will continue unabated, just in other parts of the project. Other than Dokku Pro, no features will be placed behind any paywall, nor will features be removed from the project for any reason. Users can continue to know that Dokku will stay open source, providing a great base for busy developers to get their projects deployed so they can concentrate on building great products.

We'll still be making releases over the coming months, albeit smaller ones that are more manageable in size. Hopefully the next Dokku release comes out in a month, and not 6 months!

### Dokku Pro

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

Interested in purchasing [Dokku Pro](https://pro.dokku.com/)? Dokku Pro is currently provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

### The Next Minor Release

Our next release will continue on the [7 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
