---
title:  "Dokku Release 0.23.0"
date:   2021-01-25 00:22:50 -0400
tags:
  - dokku
  - release
---

Dokku version 0.23.0 was released this weekend with quite a few major improvements for many common workflows. We'll go over major changes below.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## New Core Contributors

With the new release, a few folks have been added as contributors to the project.

- Richard Willis ([@badsyntax](https://github.com/badsyntax)) has been contributing a bit to various projects, most notably some great ideas to the official [Github Action](https://github.com/dokku/github-action).
- Milan Vit ([@cellane](https://github.com/Cellane)) has contributed significant bug reports over the past year and has been a great source of community feedback.
- Leopold Talirz ([@ltalirz](https://github.com/ltalirz)) has been the unofficial (and well, now official) steward of the Ansible Modules for quite a while now, and has made great efforts at making the code testable and reusable.

These folks have been added as Github Triagers to various projects. This means they'll have increasing control over the future of the project and features they think they'd like in the core, as well as how those things might be developed over time. You can think of them as community++ :)

While they have been added as core contributors, as this is an Open Source Project, there is no requirement of any work from them. This is simply recognition for the great work they've done to support Dokku.

How do you join? There are a number of ways to [Contribute to the project](https://github.com/dokku/dokku/blob/master/CONTRIBUTING.md), code and otherwise. As we continue to clean up various projects under the Dokku umbrella, more folks will be added (and removed as necessary) to help push the project forward. We hope that this helps unblock pull requests from being merged, features from being developed, and bugs from being squashed.

Thanks to the folks above and all community contributors. It would be hard to imagine Dokku without all of you pushin the project forward.

## Changes

### CircleCI => Github Actions

CircleCI was and remains a great service - we'll continue to use them for other projects unless there is a real need to switch. They certainly provide a wide-range of features, and will be the recommended CI stack for folks needing serious CI functionality.

That said, our CircleCI usage was limited for a few reasons:

- Parallelism limits due to using an OSS plan caused CI runs to execute for an hour+, which isn't great for quick feedback cycles.
- [Until recently](https://circleci.com/blog/our-cloud-platform-your-compute-introducing-the-circleci-runner/), CircleCI had no support for self-hosted runners. They are currently only availabe for paid plans.
- No current ARM support, making any future work towards a potential ARM version of Dokku... not possible.
- Machine images are limited in OS version, and currently only support 16.04 and 20.04 (in beta). They've also been fairly slow to add support for new OS versions (as shown by the late and still beta 20.04 support). As we continue to work on Dokku, we need to test on modern, supported operating systems, and not being able to do so limits our testing capabilities.

With 0.23.0, we've switched to Github Actions, which provides the following benefits:

- Higher parallelism, to the point that the full test suite runs in around 20 minutes.
- More varied OS and Architecture support. I for one will love the day when I can finally run Dokku on my Raspberry Pi...
- Deeper integration with Github itself.

While not all functionality has been carried over - in particular, test statistics are missing, it is impossible to re-run only failing jobs, and running jobs with SSH for debugging is a bit more difficult - it is hoped that the change makes the process of developing new functionality much easier for the average contributor.

## Bug Fixes

### Image Labeling

Dokku introduced [label-schema.org](http://label-schema.org/) support as part of 0.18.0 back in August of 2019. While Label Schema is no longer actively maintained - in favor of [OCI Annotations](https://github.com/opencontainers/image-spec/blob/master/annotations.md) tha we'll properly support in the near future - we still label images and labels according to that spec. Unfortunately, our labeling support left a lot to be desired.

- Labeling added a new layer and did not take into account previously set layers. Continued `ps:restart` calls would add the same labels over and over.
- Labels did not work for Dockerfile or Image deploys that used an `ONBUILD` directive, and would re-trigger those `ONBUILD` directives in directories that may not have a build context. We actually disabled labeling support for such images in 0.22.x.
- Intermediate containers were required for labels, causing deploys to be longer in certain cases.

As of 0.23.0, the Dokku project now uses [docker-image-labeler](https://github.com/dokku/docker-image-labeler) to inject labels only when necessary, and avoids building new containers entirely. This should have no real impact on produced images, though will reset layer create times as a side effect (a limitation that may be removed in the future).

We'll continue to investigate similar ways to speed up the build process for all of our users in future releases.

### `libpam-tmpdir` support

As part of an increased focus on security, we've added proper `libpam-tmpdir` support. The actual problem was due to how we attempt to drop permissions via the `sudo` binary without resetting certain environment variables.

While the fix was relatively simple - just unsetting some variables - our [implementation of permission dropping](https://github.com/dokku/dokku/blob/324c08a8a258800f66ee01efa7a457f36d5d42a8/dokku#L92-L99) certainly leaves something to be desired. Enterprising individuals who wish to contribute to the project and have expertise in this area would certainly be welcomed!

## New Features

### Buildpack Stack Builder Management

In previous releases, users of derivative `gliderlabs/herokuish` images would need to specify a `DOKKU_IMAGE` environment variable in order to use their version over what we ship by default. While this was a reasonable approach that worked when there was only one `herokuish` image version being maintained, we've recently decided to add support for building both `18.04` and `20.04` based images. Additionally, this approach does not work at all for our [Cloud Native Buildpack](https://dokku.com/docs/deployment/builders/cloud-native-buildpacks/) support.

As of `0.23.0`, there is now a way to set the stack builder image in use. Herokuish users (the majority of Dokku users at this time) will be able to specify either the 18.04, 20.04, or any other image as follows:

```shell
# app-specific command
dokku buildpacks:set-property $APP $SOME_IMAGE

# global command
dokku buildpacks:set-property --global stack $SOME_IMAGE
```

Any tag listed on [Docker Hub](https://hub.docker.com/r/gliderlabs/herokuish/tags?page=1&ordering=last_updated) can be used, and folks can derive their custom herokuish image as needed for their own platforms. For general users, we _highly_ recommend sticking to the shipped defaults.

Cloud Native Buildpack users have access to the same command, and can use it to specify an alternative builder image. Below switches the global builder image from `heroku/buildpacks` to the [packeto](https://paketo.io/) buildpacks maintained by CloudFoundry:

```shell
dokku buildpacks:set-property --global stack paketobuildpacks/build:base-cnb
```

We'll continue working to add full support for buildpacks commands to the Cloud Native Buildpack support, and hope this initial work makes it easier to use.

### Container Logrotation

With the addition of [Vector-based Log Shipping](https://dokku.com/docs/deployment/logs/#vector-logging-shipping) in 0.22.x, we still had a need to ensure logs didn't consume host resources. Assuming default docker log settings, it is now possible to set the [docker log retention](https://dokku.com/docs/deployment/logs/#docker-log-retention) via `logs:set`:

```shell
dokku logs:set --global max-size 20m
```

This new setting injects a property into the `docker run` calls (though is exposed via trigger for alternative schedulers), defaults to `10m`, and can be set both globally and on a per-app basis. Please rebuild your apps to have this come into effect.

### Nginx Configuration

While having a sane default is great, often-times users will need to customize their nginx proxy configuration to meet their needs. Vendoring a custom `nginx.conf.sigil` makes it more difficult for us to ship security updates to users, and thus we're opening the floodgates to new knobs for configuring the `nginx` config built for apps.

The following new properties can now be set on a per-app basis:

- `x-forwarded-for-value`
- `x-forwarded-port-value`
- `x-forwarded-proto-value`
- `client-max-body-size`

While the `hsts` property can now be set globally (default on) in addition to on a per-app basis.

We'll continue adding support to additional properties (both globally and otherwise) as the needs arise from the community. Checkout our [nginx documentation](https://dokku.com/docs/configuration/nginx/) for further details.

### Scheduled Cron Task Management

For years, we've asked folks to manage a custom cron file outside of the Dokku deployment process. While this was all well and good, it doesn't work well for less technical users or those who do not have server access. We've added support to the `app.json` file for specifying a list of commands and the schedule for which to run said commands. [Usage is simple](https://dokku.com/docs/processes/scheduled-cron-tasks/):

```json
{
  "cron": [
    {
      "command": "node run some-command-here",
      "schedule": "@daily"
    }
  ]
}
```

Scheduled cron tasks are run within isolated Docker containers, and any number of commands can be added to a given app. While this isn't currently supported in alternative schedulers, the functionality was built with such support in mind.

Checkout the [scheduled cron task documentation](https://dokku.com/docs/processes/scheduled-cron-tasks/) for more details on how the functionality works. We'd definitely love your feedback!

### Git Repository Syncing support

This is one of the more exciting features. Users may now run a command to specify a remote repository to sync - and build! - an app from via the `git:sync` command. This makes it possible to build webhook-like functionality by wrapping the command in a web api of sorts.

```shell
# just sync some code, maybe to setup a repository
dokku git:sync node-js-app https://github.com/heroku/node-js-getting-started.git

# sync and build the repository!
dokku git:sync --build node-js-app https://github.com/heroku/node-js-getting-started.git
```

We hope to continue adding interesting git-based workflows in upcoming releases, but hope that this feature is well-used by platform developers.

Thanks to [@crisward](https://github.com/crisward) for the inspiration via his [dokku-clone](https://github.com/crisward/dokku-clone) project.

## Upgrading

As with every upgrade, please see the [0.23.0 migration guide](https://dokku.com/docs/appendices/0.23.0-migration-guide/) for more information on upgrading to 0.23.0.

## 1.0?

Our versioning is getting long in the tooth, and we're quickly winding towards an eventual 1.0 release. It's been teased in the past, but as of this writing, there are currently [18 outstanding issues](https://github.com/dokku/dokku/milestone/16) in the 1.0 milestone. We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
