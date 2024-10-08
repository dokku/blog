---
title:  "Dokku Release 0.20.0"
date:   2020-04-05 00:06:00 -0400
tags:
  - dokku
  - release
---

Dokku version 0.20.0 - and a few follow-on bugfixes - was released this week with quite a few major improvements, mostly to proxying and networking. We'll go over major changes below.

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.

## Changes!

### Code Deprecations and Removals

As noted in the [migration guide](https://dokku.com/docs/appendices/0.20.0-migration-guide/), we removed quite a few default commands. These were replaced with `:help` output, and `:list` commands were provided where possible.

We've also dropped support for unsupported versions of Debian and Ubuntu. Dokku no longer runs tests on older versions of Ubuntu, and Debian support for older releases was completely untested. While newer packages may work in the future, users should upgrade their operating systems where possible.

Finally, quite a bit of code was moved into golang, and as such certain shell functions are deprecated in favor of [new plugin triggers](https://dokku.com/docs/appendices/0.20.0-migration-guide/#deprecations). Usage will trigger warnings in logging output. Please switch to the new triggers in custom plugins where possible, as we well continue to remove deprecated code in the future.

### Custom networks

In previous versions of Dokku, containers could only communicate with each other through one of the following methods:

- An intermediate datastore, whether that be a database, queuing system, or caching layer.
- Open network
- Adding `--network` docker-options flag

The first option was great for apps that were architected to do message passing, but almost a non-starter for certain self-hosted apps. Even for new apps, adding an intermediate communication layer will always increase the number of problems that could occur in a system, so it was far from optimal.

Sending traffic over the open network is not great as for many users, this would mean traffic over the internet. Sending traffic over the open network increases latency between requests, increases bandwidth usage - and costs! - and opens users to potential security issues regardless of SSL encryption. Suffice to say that this was _also_ not a great solution.

Adding a custom `--network` flag via the docker-options plugin works well enough but has a few issues itself:

- Does not allow for multiple networks
- Disables nginx traffic proxying
- Not great from a UX perspective

A user created a [custom plugin](https://github.com/ithouse/dokku-connect-network) to attach on to networks after deploy, but this also has the side effect of not supporting containers that need to talk to a specific network on boot.

With the new network support added in 0.20.0, users can easily create/destroy attachable docker networks, and ensure apps attach to those networks at the correct time for their apps via two easy-to-configure hooks. From [the documentation](https://dokku.com/docs/networking/network/#when-to-attach-containers-to-a-network):

- `attach-post-create`:
  - Phase it applies to:
    - `build`: Intermediate containers created during the build process.
    - `deploy`: Deployed app containers.
    - `run`: Containers created by the `run` command.
  - Container state on attach: `created` but not `running`
  - Use case: When the container needs to access a resource on the network.
  - Example: The app needs to talk to a database on the same network when it first boots.
- `attach-post-deploy`
  - Phase it applies to:
    - `deploy`: Deployed app containers.
  - Container state on attach: `running`
  - Use case: When another container on the network needs to access _this_ container.
  - Example: A background process needs to communicate with the web process exposed by this container.

This feature has been a long time coming - it was originally reported in 2016 - and was also a ton of work, but we hope that it provides great value to our users.

Here is a fun incoming bandwidth chart of a user switching to the new network support for their apps:

[![bandwidth decrease](/blog/assets/images/0.20.0/bandwidth-decrease.png)](/blog/assets/images/0.20.0/bandwidth-decrease.png)

See the [network documentation for more information](https://dokku.com/docs/networking/network/)

### Routing non-web containers

Users wishing to route non-web containers would previously have to either hack their nginx config or use a custom plugin to try and inject location and upstream blocks into the correct place. The lack of built-in support made it difficult to support cases where there might be a websocket process, or some command-and-conquer service that exposed a tcp connection in addition to the traditional web process.

As of 0.20.0, we now inject a custom `.DOKKU_APP_${PROCESS_TYPE}_LISTENERS` variable into all `nginx.conf.sigil` files. This will allow folks to inject http(s) processes into the nginx.conf.sigil, which brings initial support for proxying non-web processes.

Future improvements might include `tcp` support - via the nginx `stream` module - and injection of custom location blocks for even easier proxying of non-web processes.

Users are encouraged to switch their custom configs to use the new `.DOKKU_APP_WEB_LISTENERS` variable when constructing upstreams. See the [nginx template documentation for more information](https://dokku.com/docs/configuration/nginx/#customizing-the-nginx-configuration).

### HSTS Enabled by Default

If you have an SSL certificate and are proxying requests using the `nginx` plugin, then HSTS will be enabled by default. It is enabled by default - including for subdomains - though without browser preloading. Please note that the default cache setting is 182 days, so pre-configure this value if you believe you will need to manipulate HSTS support.

See the [nginx hsts documentation for more information](https://dokku.com/docs/configuration/nginx/#hsts-header).

### Restarting docker containers recover from IP changes

Docker has undefined behavior around IP address persistence when containers restart, either due to failure or because of server reboot. This has resulted in issues where restarting containers lose their IP addresses, breaking any proxy method that is associated with a container IP instead of the container name (read: how Dokku works!). This sometimes caused nasty issues where apps deployed on Dokku might mistakenly have their nginx route incorrect apps to users on server reboot, or just straight-up fail to serve requests even when the app is working after a container restart.

In 0.20.2, we included the [dokku-event-listener](https://github.com/dokku/dokku-event-listener) as a recommended package. It is usable with older versions of dokku, and can be installed like so:

```
# update your apt repository
apt update

# install it!
apt install dokku-event-listener
```

The `dokku-event-listener` daemon will properly listen to container events - start, restart, delete, destroy, die - and reload the nginx config for the related app as appropriate. It will even rebuild the application if we've hit the max container restart count. It will also output debug logging that you can use to correlate application crashes with service outages.

## Upgrading

As with every upgrade, please see the [0.20.0 migration guide](https://dokku.com/docs/appendices/0.20.0-migration-guide/) for more information on upgrading to 0.20.0.

## Future development

As Dokku continues to mature towards a [1.0](https://github.com/dokku/dokku/milestones/v1.0.0) target, the following areas will be of greater focus in upcoming releases:

- Security Improvements:
  - The [web configuration tool](https://github.com/dokku/dokku/issues/2247) is sometimes neglected by new users, which enables malicious clients to run take over servers by running arbitrary apps. We'll replace this with a page that instructs users to connect to the server and run through a sort of "first start" process.
  - SELinux is here to stay, but Dokku [does not always play nice](https://github.com/dokku/dokku/issues/3149). In an ideal world, Dokku will be well-tested in common SELinux configurations, with issues and workarounds documented for the more security-minded.
- High Availability Support: We've traditionally said that Dokku will focus on being the single-server solution for self-hosting apps, but that doesn't mean we cannot have better high availability support through official plugins and dependencies.
  - External configuration storage: The [property system](https://github.com/dokku/dokku/blob/master/plugins/common/property-functions) first pioneered in 0.12.0 for the git plugin has seen many improvements. The hope is to abstract property manipulation into a third-party project - [prop](https://github.com/dokku/prop) - that can connect to an arbitrary backend. This will require changes within Dokku to migrate to the properties system in addition to the development of the `prop` tool, but should be a great way to enable easier backups for Dokku installations from a configuration standpoint.
  - Scheduler Plugins: The [Kubernetes](https://github.com/dokku/dokku-scheduler-kubernetes) and [Nomad](https://github.com/dokku/dokku-scheduler-nomad) plugins are here to stay, though they'll need more love to become more fleshed out. While there is active development for the kubernetes scheduler plugin, neither has tight proxying integration, so users are somewhat on their own there.
  - Datastore plugins: The existing datastore plugins are meant for single-server installations. Could we wrap a project such as [KubeDB](https://kubedb.com/) or other operators to provide a nicer way of manipulating datastores in your cluster? What does this look like for Nomad? While this might be something of a dead end, it would be an interesting approach to lightly introducing Dokku users to more cloud-native methods of managing datastores.
- [Buildpack V3](https://buildpacks.io/): Dokku currently users [`gliderlabs/herokuish`](https://github.com/gliderlabs/herokuish) to provide automatic build support through buildpacks. We'll go into more detail in an upcoming post, but Cloud Native Buildpacks are the future of Dokku, and we hope that they will improve the speed and reliability of your builds.

As always, please post issues with bugs or functionality you think Dokku might benefit from. As well, feel free to hop onto our IRC or Slack channel if you have questions, comments, or concerns.

---

!!! tip

    If you're using Dokku - especially for commercial purposes - consider donating to project development via [Github Sponsors](https://github.com/sponsors/dokku), [OpenCollective](https://opencollective.com/dokku), or [Patreon](https://www.patreon.com/dokku). Funds go to general development, support, and infrastructure costs.
