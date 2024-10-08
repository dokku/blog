---
title:  "Dokku 0.27.x Wrapup"
date:   2022-08-10 00:16:09 -0400
tags:
  - dokku
  - release
---

Dokku version 0.27.0 was released a few months ago. This post covers the important changes that occurred throughout the lifetime of the 0.27.x series. A future post will cover the 0.28.0 release.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Additions

### OS and Architecture Support

Ubuntu Focal was added as a release target. We also added support for ARM (32-bit) and ARM64 architectures. Users on Raspberry Pis should be able to install the latest Dokku, regardless of OS or Architecture.

Additionally, the Dokku docker image is now based on Focal :)

### App and service filtering

It is now possible to filter apps and services via the `user-auth-app` and `user-auth-service` triggers. These can be implemented in custom plugins to constrain what a user has access to, and is in use within [Dokku Pro](https://pro.dokku.com) for it's [team-management system](https://pro.dokku.com/docs/features/teams-management/).

## Fixes

### App domain renames are scoped to global domains

Previously, if you had an app named `test` with a domain of `tester.com` and renamed it to `test-2`, we would rename the domain to `test-2er.com`. We've now scoped this so app renames only impact domains associated with any global domains on the server.

### Remove bad intermediate containers

Due to how Dokku handles the build process, intermediate containers reuse the internal docker image name for an app. This means that it is sometimes possible to execute `dokku run` against an intermediate image.

Dokku now properly removes intermediate images if the build fails.

### Support for special characters in docker container options

Dokku now supports using special characters, such as parenthesis, in container options. Here is an example:

```shell
dokku docker-options:add node-js-app deploy '--label "some.key=Host(\`node-js-app.dokku.arketyped.net\`)"'
```

Some characters should be escaped - and quoting matters! - but label-based proxy-implementations can now take full advantage of apps deployed via Dokku.

## Upgrading

As with every upgrade, please see the [0.27.0 migration guide](https://dokku.com/docs/appendices/0.27.0-migration-guide/) for more information on upgrading to 0.27.0.

## It's a wrap

Those were the major changes in 0.27.x. Our next post will cover 0.28.0!

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
