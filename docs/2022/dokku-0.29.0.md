---
title:  "Dokku Release 0.29.0"
date:   2022-12-24 16:52:00 -0400
tags:
  - dokku
  - release
---

The last minor release of the year is here! Here is a summary of what is new in [0.29.x](https://github.com/dokku/dokku/releases/tag/v0.29.0).

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Changes in 0.29.x

### File extraction moved from image to repository

Previously, Dokku would build the app image - via whichever builder was specified - and then extract files from the built image. This allowed some level of customization of certain files - such as generating a `Procfile` or `nginx.conf.sigil` during the build process based on environment variables. However, the logic is a bit contrary to how we handle other files in mono-repo setups.

With 0.29.x, we now extract files from the repository source code where possible. This allows our monorepo codebase handling to act the same everywhere and also speeds up app builds.

!!! note

    The current notable exception to the new extraction process is the `app.json` file, which will be fixed in the next minor release.

### App domains are now setup at app creation time

Previously, domains were attached to apps when proxy configuration was first generated. This caused issues when domains were referred to prior to the first app deploy. Dokku will now instead associate app domains on app creation, and users may later remove the domains as desired.

One side effect of this is the refactor of how domains and app urls are referred to within Dokku. Please see the [migration guide](https://dokku.com/docs/appendices/0.29.0-migration-guide/) for more details how how this might impact your usage of Dokku.

## New in 0.29.x

### `run` subcommand additions

We've added a few new commands to the built-in `run` plugin:

- `run:logs`: Fetches live log output for all one-off `run` containers. For those that wish to persist logs, checkout Dokku's [Vector integration](https://dokku.com/docs/deployment/logs/#vector-logging-shipping)
- `run:stop`: Stops a one-off `run` container.

We've also added JSON output support for the `run:list` command, making it easier to manipulate in a programmatic manner.

### Initial herokuish support on ARM servers

While Dokku has supported ARM/ARM64 servers for a while, Herokuish - the most common builder in use with Dokku - has not. While it is possible to make a buildpack ARM-compatible, the majority are not, and thus we blocked off the functionality to avoid causing issues for users.

For more adventurous Dokku users, the herokuish builder can now be enabled on ARM/ARM64 servers (though it is not enabled by default). Individual buildpacks will still need to have support added for ARM/ARM64 platforms, but users are no longer artificially limited by Dokku to other builders.

## Upgrading

As with every upgrade, please see the [0.29.0 migration guide](https://dokku.com/docs/appendices/0.29.0-migration-guide/) for more information on upgrading to 0.29.0.

## Dokku Pro

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

Interested in purchasing [Dokku Pro](https://pro.dokku.com/)? Dokku Pro is currently provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

## The Next Minor Release

Our next release will continue on the [8 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
