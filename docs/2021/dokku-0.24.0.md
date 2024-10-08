---
title:  "Dokku Release 0.24.0"
date:   2021-03-04 00:17:29 -0400
tags:
  - dokku
  - release
---

Dokku version 0.24.0 was released earlier this week with a few new features that some power users may find useful. We'll go over major changes below.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Changes

### Change exit code when app does not exist

This will allow wrappers around dokku to avoid needing two calls to dokku - one for apps:exists, the other for the command you want to run itself - to see if the app does not exist or if the error was something else.

Builders of UI systems on top of Dokku may wish to take advantage of this functionality to decrease the number of calls they need to make to Dokku.

Finally, plugin developers should always use `verify_app_name()` (shell) and `common.VerifyAppName()` (go) when verifying the app name to ensure they also receive this same functionality.

## New Features

### Support for heroku's `postdeploy` deployment task

Our existing deployment task support covered a wide range of use cases, but of course did not implement Heroku's own `postdeploy` support. This deployment task is commonly used to seed data into apps, especially for Heroku's "review app" functionality.

As of 0.24.0, Dokku implements support for Heroku's `postdeploy` hook. This is currently triggered during the `postdeploy` on the first deploy of an app, mimicking heroku. It currently happens after the `release` task, during the `pre-deploy` trigger, which more or less mimics the `release` phase.

### Git Authentication handling via .netrc

With the new `git:sync` functionality introduced in `0.23.0`, users of private repositories immediately saw an issue with their ability to use the feature. To enable those users to deploy private apps, the [`netrc`](https://github.com/dokku/netrc) binary was built, and a wrapper `git:auth` command was added to Dokku.

This new command allows users to specify custom git server authentication information for use with `git:sync` by modifying the `~dokku/.netrc` file. The alternative is to use ssh keys, which is still supported.

This PR additionally outputs an error message when we detect an auth error:

```
There is no deploy key associated with the dokku user.
Generate an ssh key with the following command (do not specify a password):
  ssh-keygen -t ed25519 -C 'example@example.com'
As an alternative, configure the netrc authentication via the git:auth command
```

This should allow folks to figure out what they need to do.

Lastly, the clone/fetch commands no longer use `-qq` or stderr redirection. If there are other errors, this will allow operators to have some debugging information.

### Simplified docker image deployment via `git:from-image`

There are a ton of people that want to deploy a docker image. To do that, they currently need to:

- pull the image via `docker pull`
- `tags:deploy` it
- avoid `ps:rebuild`, which ignores `tags:deploy`
- avoid git repositories, which will result in breaking `tags:deploy`

The above doesn't quite work without root server access, so anyone who only exposes the dokku user cannot use the above workflow without an extra plugin.

They can also do a git repository workflow - creating a repository, updating it with the built image, pushing it - but there are more than a few steps needed to do that correctly and keep history.

Pull Request [#4450](https://github.com/dokku/dokku/pull/4450) implements `git:from-image`. Under the hood, this command creates or updates the git repository for the app with the specified image. The workflow implements all the above steps for users in a way that allows ignoring direct exposure of `docker pull` as a Dokku command (which would open the flood gates to all docker commands). It also keeps the git workflow (so you get history) and enables a whole class of users to properly deploy docker images.

There is other stuff this might enable, like an app library, but the main idea is to enable a class of users that has been typically under-served.

For `tags` plugin users, note that this functionality deprecates the `tags` plugin, which will be removed in the next minor release. Please migrate any workflows currently using the `tags` plugin to `git:from-image`.

### Simplified archive deployment via `git:from-archive`

Similar to `git:from-image` - and using the same internal infrastructure to manage history - there is a new `git:from-archive` command. This new command supports deploying `.tar`, `.tar.gz`, and `.zip` files to apps, keeping git history with every deploy. In addition to a url, it also supports piping the archive in via stdin.

The `git:from-archive` command is meant to be used in cases where the deployment model is to deploy from a git tag. This may mean that the artifact is already built and just needs extraction, or can continue to use the normal build process available in Dokku.

For `tar` plugin users, note that this functionality deprecates the `tar` plugin, which will be removed in the next minor release. Please migrate any workflows currently using the `tar` plugin to `git:from-image`.

### Specifying app builders

Dokku currently supports three different types of app builders:

- Dockerfile
- Herokuish (for Buildpack Heroku v2a compatibility)
- Pack (for Cloud Native Buildpacks compatibility)

The specification of the app builder is somewhat hard-coded and actually annoying for users that wish to use a specific builder for their app. In addition, it was impossible to inject your own custom builder, frustrating folks that have very specific constraints about how they generate Docker images.

Rather than hardcode the various builders, this new feature allows builder plugins to specify a `builder-detect` trigger. This trigger can be used to specify if the builder should or should not be used for an application. Each builder takes the app directory and can decide if it should emit it's own image source type.

If the final list of detected builders is empty, then Dokku will default to herokuish (and `pack/CNB` once that is stable). Users may also override the builder via the `builder:set` command.

This change enables users to build custom builder plugins and have those plugins used for building an image asset. By way of example, an enterprising user could create a `builder-lambda` based on lambci, and then pair this with a scheduler plugin that updates a lambda function on AWS. Alternatively, a user might decide they wish to place their Dockerfile in a specific directory for their applications - such as an `_infrastructure` directory - and create a plugin to override how that is detected within Dokku.

An enterprising user has already built a [`builder-nix`](https://github.com/jameysharp/dokku-builder-nix) plugin that builds Docker images via NixOS.

### Parallelism for some proxy commands

Being able to specify `--all` and increase parallelism of save commands is always great. As of 0.24.0, the commands `proxy:enable`, `proxy:disable` and `proxy:build-config` now support the `--all` flag in addition to general parallelism.

If parallelism is needed for a specific command, please file an issue to get it added :)

## Upgrading

As with every upgrade, please see the [0.24.0 migration guide](https://dokku.com/docs/appendices/0.24.0-migration-guide/) for more information on upgrading to 0.24.0.

## The Next Minor Release

Our next release will continue on the [16 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We hope to knock out a few of these, especially those related to Dockerfile and ports handling. We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
