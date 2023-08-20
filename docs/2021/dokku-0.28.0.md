---
title:  "Dokku Release 0.28.0"
date:   2021-09-06 12:00:00 -0400
tags:
  - dokku
  - release
---

It's been a little over two weeks since our 0.28.x release landed. Here is a summary of what new stuff is in 0.28.x.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

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

As with every upgrade, please see the [0.28.0 migration guide](/docs/appendices/0.28.0-migration-guide.md) for more information on upgrading to 0.28.0.

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
