---
title:  "Dokku Release 0.26.0"
date:   2021-11-09 10:46:00 -0400
tags:
  - dokku
  - release
---

It's been a little over two weeks since our 0.26.x release landed. Here is a summary of what features were added during the 0.25.x release and new stuff in 0.26.x.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## New Features during the 0.25.x Series

### Debian Bullseye Support

[#4742](https://github.com/dokku/dokku/pull/4742)

Dokku has supported both Debian and Ubuntu for quite a while - our packages are universal and actually can be installed all the way back to Ubuntu 14.04, even though we no longer officially support it. Bullseye came in a few days after the 0.25.0 release, so adding support for it made total sense.

### Faster Herokuish builds when injecting environment variables

[#4741](https://github.com/dokku/dokku/pull/4741)

Previously, herokuish buildpack builds would use intermediate containers for injecting the initial environment variables during the build process. This was actually quite slow - a container is created, started, some command is run, and then we create the image from that container - and also sometimes resulted in leftover containers if a build failed.

We now initialize app environment variables via a special Dockerfile, which skips the intermediate container completely. Not only is this a bit faster, but we also no longer need to cleanup after the intermediate container.

### VSCode Remote Container Support

[#4785](https://github.com/dokku/dokku/pull/4785)
[#4791](https://github.com/dokku/dokku/pull/4791)
[#4800](https://github.com/dokku/dokku/pull/4800)
[#4814](https://github.com/dokku/dokku/pull/4814)

For anyone doing Dokku development, being able to simulate the entire environment is :major: :key: for productivity. Setting up a virtual machine can be:

- Slow: you are competing for system resource during the build
- Error Prone: Virtualbox doesn’t work for me, but also the entire build may fail if you are not on a network
- Impossible: Our development environment isn’t tested at all on Windows, knocking off a ton of potential contributors

We’ve since added more complete support for developing in VSCode’s Remote Container environment. In the future, supporting Azure and GitHub dev containers is in the cards, but this should enable most developers to more smoothly develop, test, and contribute to Dokku.

### Schedule Process Types in Parallel

!!! note

    This functionality was graciously sponsored by [Rechat](https://rechat.com/), a company doing remarkable efforts to help simplify and elevate how Real Estate Agents and Brokers operate. 

[#4829](https://github.com/dokku/dokku/pull/4829)

Previously, we would deploy each container process type one at a time. For most users, this was not a _huge_ deal, but users deploying apps with 10+ apps would encounter multi-minute deploys.

As of 0.25.5, users can set the parallelism on processed process types. The `web` process is now always deployed first, while all other processes will deployed after the fact. The following command will set parallelism to 4 (default: 1) for non-web processes:

```
dokku scheduler-docker-local:set $APP parallel-schedule-count 4
```
This only applies to the list of process types scheduled at once, not individual containers within a process type.

## Changes in 0.26.x

### Removal of deprecated `tags` and `tar` plugins

[#4858](https://github.com/dokku/dokku/pull/4858)
[#4859](https://github.com/dokku/dokku/pull/4859)

These two plugins were previously deprecated in 0.24.x in favor of git:from-image and git:from-archive, respectively. Rather than keep an unmaintained, buggy implementation of deployment, we’ve completely removed these two plugins. Users should switch to the recommended methods of deployment, which are much more flexible and better integrate with Dokku.

### Faster restarts and single-process restarts

[#4765](https://github.com/dokku/dokku/pull/4765)

Previously a restart would result in a complete rebuild of an application. With this change, restarts will now only rebuild when the image does not exist, and otherwise simply restart processes with the built image.

In addition, a user may restart _just_ a single process type. While not common, this can be used as a proxy for killing processes that consume memory, while not requiring a full app rebuild or restart.

### Increase parallelism for containers within specific process types

[#4860](https://github.com/dokku/dokku/pull/4860)

As a followup to [#4829](https://github.com/dokku/dokku/pull/4829), apps deployed via the docker-local scheduler can now perform parallel scheduling for specific process types. The default configuration follows the existing behavior, while engineers that need extra parallelism on a per-process type basis can configure it via the `app.json` file:

```
{
    “formation”: {
        “web”: {
            “max_parallel”: 3
        }
    }
}
```

Parallelism defaults to 1 (previous behavior) but can be increased as needed.

### Scheduler Management Plugin

[#4857](https://github.com/dokku/dokku/pull/4857)

As we move towards a 1.0 release, Dokku’s internal configuration that can be modified via environment variables is being moved into plugin-specific configuration settings. Setting a scheduler is one of them, and 0.26.0 will migrate the `DOKKU_SCHEDULER` environment variable to a `scheduler` plugin setting. Going forward, should set the scheduler via `scheduler:set [app|—global] selected` call.

### Raspberry PI Support

[#4885](https://github.com/dokku/dokku/pull/4885)
[#4887](https://github.com/dokku/dokku/pull/4887)
[#4888](https://github.com/dokku/dokku/pull/4888)
[#4889](https://github.com/dokku/dokku/pull/4889)

Dokku has always lived in the realm of self-hosting, but it was always x86-based. This completely precluded ARM users from using Dokku, which wasn’t great for those who _fully_ self-hosted, servers included.

In the first few releases of 0.26.x, we’ve added `armhf ` architecture support, allowing those using Raspbian to install Dokku. Adding support for other ARM architectures should be rather trivial in the future (provided there is Golang support).

Some notes:

- Herokuish builds will never be supported as the heroku Buildpacks only support x86.
- Cloud Native Buildpack usage `pack` does not currently support ARM, though we will be helping upstream to get that rolling so developers can use Cloud Native Buildpacks.
- Dockerfile builds should work if your base image works on ARM. 

While there are some limitations, the general Dokku experience works quite well on ARM, and hopefully opens up experimentation to the general development community.

## Upgrading

As with every upgrade, please see the [0.26.0 migration guide](https://dokku.com/docs/appendices/0.26.0-migration-guide/) for more information on upgrading to 0.26.0.

## Dokku Pro

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

We'll have more information in the coming week, but Dokku Pro will be provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

## The Next Minor Release

Our next release will continue on the [9 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
