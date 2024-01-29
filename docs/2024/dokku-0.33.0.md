---
title:  "Dokku Release 0.33.0"
date:   2024-01-29 14:07:00 -0400
tags:
  - dokku
  - release
---

The first release of the year is here! Here is a summary of what is new in [0.33.x](https://github.com/dokku/dokku/releases/tag/v0.33.0).

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## New in 0.33.x

### User namespace support for interacting with persistent storage

While Dokku has had partial support for [custom Docker user namespaces](https://docs.docker.com/engine/security/userns-remap/) for a while, persistent storage has always been an issue. Users of persistent storage backed by local directories would have directories mounted with incorrect permissions.

Dokku now automatically detects user namespace remapping and will increase the ownership on the folders created via `dokku storage:ensure-directory` to match the namespace IDs. This should allow for more secure container isolation for security conscious users.

### Deploy Key generation

Many users of Github are familiar with the concept of a [deployment key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys), but if you aren't, they allow access via `git+ssh` to a given remote repository. Deployment keys are a simple way of cloning a remote repository, and Dokku users have long used the community [deployment-keys](https://github.com/cedricziel/dokku-deployment-keys) plugin.

While most repositories can be authenticated to via the `git:auth` command, some users may prefer to use an ssh key. As of 0.33.x, this can be generated via the `git:generate-deploy-key` command, which generates a passwordless ed25519 key-pair:

```shell
dokku git:generate-deploy-key
```

In order to clone a remote repository, the remote server should have the Dokku host's public key configured. The generated key can be shown via the `git:public-key` command.

```shell
dokku git:public-key
```

Note that the `git:auth` method provides a more secure way of access remote repositories based on matching a host to a user/token combination, and should be preferred where possible.

### Automatically detecting AMD64 image platform on ARM64 servers

While users could previously build AMD64-based images on ARM64 servers, deploying them was another issue. Containers would be started with an incorrect platform, resulting in failure to boot.

Dokku now automatically injects the correct platform for AMD64 images deployed on ARM64 servers. This should allow folks to have running applications while slowly migrate image builds to ARM64.

### Support for setting a global proxy type

Previously, changing the proxy implementation from the default `nginx` proxy to any other implementation - `caddy`, `haproxy`, `openresty`, `traefik` - had to be done on a per-app basis. This made it more cumbersome to provision new applications for users that switched to another proxy implementation.

Dokku users can now specify a global proxy type, avoiding the need for any post-creation steps:

```shell
dokku proxy:set --global caddy
```

### Docker Registry Image Repo templates

In the same vein as setting a global proxy type, users who build and push apps to a remote docker registry _also_ had to specify the image repo each time. Image repositories are usually app-specific, and doubly so for Dokku, which uses an increasing integer value for each built image.

With Dokku 0.33.x, a global image template can now be specified:

```shell
dokku registry:set --global image-repo-template "dokku/{{ .AppName }}"
```

The template uses golang templating and provides an `AppName` variable for use. Users can there use any repo prefix they'd like, allowing for usage against registries such as Docker Hub where the namespace is specific to a given user (and therefore none can use the default `dokku/` prefix):

```shell
dokku registry:set --global image-repo-template "my-awesome-prefix/{{ .AppName }}"
```

### Integrated Kubernetes support with the K3s scheduler

!!! note

    This functionality was graciously sponsored by [Rechat](https://rechat.com/), a company doing remarkable efforts to help simplify and elevate how Real Estate Agents and Brokers operate. The Dokku project is grateful to their sponsorship of this and other Dokku functionality.

Long-time users will know that Dokku is an extensible framework used for building and releasing applications. It comes with multiple plugins for building (Dockerfile, Nixpacks, Buildpacks, Lambda functions), proxying (caddy, haproxy, nginx, openresty, traefik), and other parts of the system. We've also long had Kubernetes and Nomad support with external plugins, though these were more difficult to setup and therefore not often used.

Dokku 0.33.x introduces a new official `k3s` core plugin which bridges the gap between single and multi-server usage. This builds upon improvements to other parts of Dokku - such as changes to the proxy layer, cron integration, registry support - to provide a simple-to-use Kubernetes experience.

Starting a single-node cluster is simple:

```shell
dokku scheduler-k3s:initialize
```

And with a few more commands, Dokku will be ready to deploy your application to Kubernetes. We also make it easy to add new server and workers to your cluster:

```shell
dokku scheduler-k3s:cluster-add ssh://root@worker-1.example.com
```

With `k3s` as the plumbing, Dokku provides a great experience for those that need high availability but find onboarding to Kubernetes difficult. Simply spin up some servers, connect Dokku to them, and deploy as normal.

While the `k3s` integration is in it's infancy, it supports much of the underlying Dokku functionality. Users can expect most commands - fetching logs, entering containers, running arbitrary commands - to work with the `k3s` scheduler as they work with `docker-local`, and missing functionality will be added over time. Users of the `docker-local` scheduler can also expect things to continue working as normal, with no need to interact with `k3s` at all if the functionality is not in use.

There will be an upcoming FAQ posted regarding k3s/kubernetes plans in Dokku and how it's addition impacts the Dokku project/ecosystem, but users can follow [this tutorial](https://dokku.com/tutorials/other/deploying-to-k3s/) to setup a new server that uses `k3s` as it's scheduler.

## Future Plans

### K3s support

While we've added preliminary Kubernetes support via the `k3s` scheduler, there are a number of improvements to do:

- Making it easy to join an existing k3s cluster
- Adding support for generic Kubernetes clusters
- Scale-to-zero support and autoscaling
- Support for alternative proxy implementations
- Further integration with existing Dokku features

We hope to have more comprehensive support over the next few releases. Stay tuned!

### Dokku Pro

With the release of Dokku 0.33.x, there is finally some breathing room to concentrate on Dokku Pro. A new release with api and ui additions for user and team management are coming, and there are improvements in the pipeline that will make future development much quicker!

Dokku Pro is a commercial offering that provides a familiar Web UI for all common tasks performed by developers. End users can expect an interface that provides various complex cli commands in an intuitive, app-centric manner, quickly speeding up tasks that might otherwise be difficult for new and old users to perform. Additionally, it provides a way to perform these tasks remotely via a json api, enabling easier, audited remote management of servers. Finally, Dokku Pro provides an alternative, https-based method for deploying code which can be used in environments that lockdown ssh access to servers.

Interested in purchasing [Dokku Pro](https://pro.dokku.com/)? Dokku Pro is currently provided under early bird pricing (with the price going up as we continue to release new versions). Server licenses are sold in perpetuity, so lock in lower pricing today!

<a data-dpd-type="button" data-text="PURCHASE NOW" data-variant="price-right" data-button-size="dpd-large" data-bg-color="469d3d" data-bg-color-hover="5cc052" data-text-color="ffffff" data-pr-bg-color="ffffff" data-pr-color="000000" data-lightbox="1" href="https://dokku.dpdcart.com/cart/add?product_id=217344&amp;method_id=236878">Purchase Now</a><script src="https://dokku.dpdcart.com/dpd.js"></script>

### The Next Minor Release

Our next release will continue on the [7 outstanding 1.0 issues](https://github.com/dokku/dokku/milestone/16). We encourage folks to take a peak at them and help investigate bugs, come up with work plans, or contribute PRs where possible to help bring us over the finish line.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop into [Github Discussions](https://github.com/dokku/dokku/discussions) or [Slack channel](https://slack.dokku.com/) if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
