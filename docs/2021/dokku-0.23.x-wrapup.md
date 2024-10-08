---
title:  "Dokku 0.23.x Wrapup"
date:   2021-03-04 00:01:10 -0400
tags:
  - dokku
  - release
---

Dokku version 0.24.0 was released earlier this week. This post covers the major changes that occurred throughout the lifetime of the 0.23.x series. A future post will cover the 0.24.0 release.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Additions

### Release changes

Dokku now has support for triggering releases via Github Actions. This will allow any maintainer to make a release of Dokku without needing to set anything up locally. The ability to auto-release plugins and tools in the Dokku ecosystem will slowly be added to all core projects over the coming weeks.

In addition, we now update the official Azure ARM template for Dokku during the release process, as well as bump the homebrew repo for the remote cli tool. We hope to extend this official release bumping to other image maintained for Dokku in the near future.

### Report output as json

While undocumented, all of the golang plugins now support displaying report output as json ([#4369](https://github.com/dokku/dokku/pull/4369)). This makes it easier for tools to parse the reports.

A future release will hopefully extend this to all plugins, and provide a framework for non-core plugins to also have json formatting support in `:report` output.

### Modifying `X-Forwarded-Ssl` in nginx configurations

Some load balancers require specifying a value for `X-Forwarded-Ssl`. The ability to do so was added in [#4420](https://github.com/dokku/dokku/pull/4420). Note that this is a non-standard version of setting `x-forwarded-proto` to `https`, and should only be done as a last resort.

### Add support for injected cron entries from external plugins

One of the things lost by the addition of scheduled cron task support in 0.23.0 was the ability to set cron tasks from plugins. This functionality was used by the dokku-letsencrypt plugin to support it's auto-renew functionality.

The change in [#4384](https://github.com/dokku/dokku/pull/4384) allows alternative plugins - such as dokku-letsencrypt - to inject scheduled cron tasks into the cron system used by Dokku. Cron systems can choose to include or not include a cron task based on the specified scheduler, and can also optionally use a third parameter to store arbitrary information.

### Ability to clear an individual resource value

As of (#4372)[https://github.com/dokku/dokku/pull/4372], a resource value can be individually cleared by setting the value to the special value `clear`.

```shell
dokku resource:limit --cpu clear node-js-app
```

```
=====> Setting resource limits for node-js-app
       cpu: cleared
```

### A new 'null' buildpack was added

Herokuish 0.5.25 introduces a new `null` buildpack. This buildpack does nothing, which is useful if your app vendors all it's dependencies and does not need to be built.

To use it, include a `.null` file in your app repository. No other changes are necessary.

## Changes

### Documentation is now at dokku.com

The documentation has moved from the global viewdocs to it's own fork, hosted at [dokku.com](https://dokku.com). Future documentation changes will enable embedded docs for official plugins, doc search, as well as including the blog on the main domain.

As an added bonus, our documentation now has SSL!

### Checking if an app was deployed

Previously, checking if an app was deployed actually checked if there were any running processes. This is not only incorrect, but also fails to take into account applications that do not have running processes and are only used for one-off commands.

The fix in [#4402](https://github.com/dokku/dokku/pull/4402) migrates apps to the new "deployed" property which is set in core-post-deploy. The result is a slightly faster "deployed" check that is correct and allows non-scaled apps to actually work.

### Better Procfile extraction

As of [#4373](https://github.com/dokku/dokku/pull/4373), the Procfile is now extracted in the pre-deploy step for every deploy and otherwise not removed. Thus, it should always exist when necessary - web will be scale to 1 automatically and it won't need to be present on future ps:scale calls since we'll have the scale file - and the command can execute faster.

## Upgrading

As with every upgrade, please see the [0.23.0 migration guide](https://dokku.com/docs/appendices/0.23.0-migration-guide/) for more information on upgrading to 0.23.0.

## It's a wrap

And that's it for 0.23.x. Our next post will cover 0.24.0, as well as plans for future releases.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
