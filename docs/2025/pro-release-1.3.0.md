---
template: blog.html
description: >
  Dokku Pro 1.3.0 introduces user and team management in the UI while revamping
  the internal design of the product.
---

__The 1.3.0 release introduces user and team management in the UI while revamping
the internal design of the product.__

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

---

With the initial release of Dokku Pro 1.2.0, we introduced a flexible team-based
access control system. This was a great step forward, but the implementation
was not without it's issues.

In this release, we've added user and team management in the UI, allowing system
administrators to manage users and teams, while delegating the ability to manage
apps and services to team members.

Here are a few of the updates included in Dokku Pro 1.3.0.

## Major Changes

### Requires Dokku 0.35.15Z+

!!! warning
    Dokku Pro 1.2+ will refuse to start if the minimum Dokku version is not installed.

The minimum Dokku version increase was made to support new functionality in
Dokku Pro. The previous 1.2.0 version required at least 0.27.8, which was released
in July of 2022. Users are encouraged to upgrade to the latest version of Dokku
prior to upgrading Dokku Pro.

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

### Minimum required service plugin versions

!!! warning
    Dokku Pro 1.2+ will refuse to start if an installed plugin is not at the
    minimum supported version.

As a reminder, it is also recommended to update all service plugins to ensure
services are properly listed in the API and UI. In addition, the upgrades are
necessary for support for deferred app rebuilds during service linking. Without
them, service linking may time out.

Certain new functionality in Dokku Pro required changes to the service plugins.

Here are the versions necessary for this release of Dokku Pro:

| Plugin                                                        | Version |
| --------------------------------------------------------------|---------|
| [clickhouse](https://github.com/dokku/dokku-clickhouse)       | 1.42.0  |
| [couchdb](https://github.com/dokku/dokku-couchdb)             | 1.27.0  |
| [elasticsearch](https://github.com/dokku/dokku-elasticsearch) | 1.36.0  |
| [graphite](https://github.com/dokku/dokku-graphite)           | 1.36.0  |
| [mariadb](https://github.com/dokku/dokku-mariadb)             | 1.41.0  |
| [meilisearch](https://github.com/dokku/dokku-meilisearch)     | 1.46.2  |
| [memcached](https://github.com/dokku/dokku-memcached)         | 1.36.3  |
| [mongo](https://github.com/dokku/dokku-mongo)                 | 1.38.1  |
| [mysql](https://github.com/dokku/dokku-mysql)                 | 1.41.1  |
| [nats](https://github.com/dokku/dokku-nats)                   | 1.37.0  |
| [omnisci](https://github.com/dokku/dokku-omnisci)             | 1.36.0  |
| [postgres](https://github.com/dokku/dokku-postgres)           | 1.41.0  |
| [pushpin](https://github.com/dokku/dokku-pushpin)             | 1.40.0  |
| [rabbitmq](https://github.com/dokku/dokku-rabbitmq)           | 1.38.2  |
| [redis](https://github.com/dokku/dokku-redis)                 | 1.39.1  |
| [rethinkdb](https://github.com/dokku/dokku-rethinkdb)         | 1.36.0  |
| [solr](https://github.com/dokku/dokku-solr)                   | 1.30.1  |
| [typesense](https://github.com/dokku/dokku-typesense)         | 1.39.0  |

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

### User Management

While managing teams via the CLI is great, we still need a way to create users.
Specifically, we need a way to create users that can interact with the API and UI,
as the existing user system in Dokku is designed to be used via SSH keys.

To address this, we've added a new `dokku user` command that allows system
administrators to create users that can be used to authenticate against the API
and UI. These users are stored on disk, can have their passwords reset, and
compliment the existing SSH key-based authentication system. In the future, we
will be able to add token-based authentication as well, allowing for bot-based
interactions with the API.

This feature applies to both the cli and the API, and is fully integrated with
the existing team management system.

Checkout the [user management documentation](/docs/features/user-management/)
for more information on how user-based access control works.

### Team and User Management in the UI

In addition to the CLI commands, we've also added team and user management to
the Web UI. Admins can now create, update, and delete users and teams, while
users can now login and access applications and services they have been
granted access to.

Checkout the [team management documentation](/docs/features/team-management/)
for more information on how team-based access control works.

## Minor Changes

Some of the more minor changes were made to make development of Dokku Pro itself
much more pleasant. Rather than having a "miscellaneous bug fixes and improvements"
section as you'd see in many other public product release notes, we'll outline
them below.

#### Updated Dependencies

Dokku Pro uses a ton of code itself. We've started the efforts to get the
server-side code up to date in an automatic fashion, and are ramping up efforts
to modernize the Web UI as well.

#### Migration to React and NextJS

The initial Web UI was written in VueJS, and while it served us well, it was
a bit of a pain to work with. We've now migrated the Web UI to React and the latest
version of NextJS, making it easier to work with and more maintainable. This was a
considerable undertaking - the entire web UI had to be rewritten from scratch! -
but we believe the results are worth it.

While we've done extensive work to ensure the new Web UI is a drop-in replacement
for the old one, there are a few known issues and missing features. These will be
filled in over the next few weeks. Stay tuned for updates in your inbox!

#### Team management commands

A few new commands were added to help manage teams and users. These are:

- `dokku team:commands-set` - Set the commands available to a team
- `dokku team:apps-set` - Set the apps available to a team
- `dokku team:services-set` - Set the services available to a team
- `dokku team:members-set` - Set the members of a team
- `dokku team:owners-set` - Set the owners of a team

These commands are used to enforce specific permissions for teams, allowing for more
declarative team management.

Checkout the [team management documentation](/docs/features/team-management/)
for more information on these commands.

#### ARM64 support

With the rapid adoption of ARM64 architecture, we've added support for it in
Dokku Pro. Anyone installing Dokku Pro on an ARM64 machine - such as the Raspberry Pi,
AWS Graviton2, Oracle Ampere, or any other ARM64 machine - can now install Dokku Pro
and enjoy the same features as x86_64 users.

## Dokku Pro Pricing

This release does not include any pricing changes. Dokku Pro's price will continue to
increase over time by various amounts until the product settles to a more "feature-complete"
state.

Please bear in mind that this is a lifetime license, and users are entitled to
all upgrades of Dokku Pro as long as they are made. Folks wishing to support
continued development of the project are encouraged to purchase today before the
price is increased.

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

## Coming up next?

This release has been a long time coming, and we're excited to get it out to you.
We've got a few more features we'd like to add to Dokku Pro, and are hard at work
on them. Here is what we'll be working towards over the next few releases

- Improvements to service UI interactions
- Exposing HTTP Auth and Maintenance mode in the Web UI
- More APIs for core Dokku functionality!
- Persistent Storage management

With this release out of the way, we'll also be shifting our focus to issues raised
in the [issue tracker](https://github.com/dokku/dokku-pro-issues/issues). The massive
number of internal refactors have made it easier for us to add new features, and
we're excited to finally getting some of the requested items out to you! Have a feature
request or bug complaint? Feel free to file it in the issue tracker
[here](https://github.com/dokku/dokku-pro-issues/issues).

Thanks everyone for there support during this endeavor, and I hope you all enjoy
this release of Dokku Pro!
