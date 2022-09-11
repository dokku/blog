---
template: blog.html
description: >
  Dokku Pro 1.2.0 introduces team-based access control while improving on it's
  internal design
---

__The 1.2.0 release introduces team-based access control and many internal
refactors aimed at easing future development of the product.__

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

---

Dokku has traditionally been a single-tenant PaaS solution, where all users
had access to all functionality on the server. While there were community
plugins that tackled authentication, each implementation had it's rough edges due
to interfaces in Dokku itself. Dokku Pro 1.2.0 polishes those edges while
introducing a flexible permission system for organizations that need it.

Here are a few of the updates included in Dokku Pro 1.2.0.

## Major Changes

### Requires Dokku 0.27.8+

!!! warning
    Dokku Pro 1.2+ will refuse to start if the minimum Dokku version is not installed.

The minimum Dokku version increase was made to support new functionality in
Dokku Pro. The previous 1.1.0 version required at least 0.27.0, so hopefully
this upgrade does not cause too many issues for folks.

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
| [clickhouse](https://github.com/dokku/dokku-clickhouse)       | 0.17.0  |
| [couchdb](https://github.com/dokku/dokku-couchdb)             | 1.25.0  |
| [elasticsearch](https://github.com/dokku/dokku-elasticsearch) | 1.24.0  |
| [graphite](https://github.com/dokku/dokku-graphite)           | 1.22.0  |
| [mariadb](https://github.com/dokku/dokku-mariadb)             | 1.24.0  |
| [meilisearch](https://github.com/dokku/dokku-meilisearch)     | 0.6.0   |
| [memcached](https://github.com/dokku/dokku-memcached)         | 1.22.0  |
| [mongo](https://github.com/dokku/dokku-mongo)                 | 1.21.0  |
| [mysql](https://github.com/dokku/dokku-mysql)                 | 1.23.0  |
| [nats](https://github.com/dokku/dokku-nats)                   | 1.24.0  |
| [omnisci](https://github.com/dokku/dokku-omnisci)             | 1.23.0  |
| [postgres](https://github.com/dokku/dokku-postgres)           | 1.24.0  |
| [pushpin](https://github.com/dokku/dokku-pushpin)             | 0.14.0  |
| [rabbitmq](https://github.com/dokku/dokku-rabbitmq)           | 1.24.0  |
| [redis](https://github.com/dokku/dokku-redis)                 | 1.24.0  |
| [rethinkdb](https://github.com/dokku/dokku-rethinkdb)         | 1.21.0  |
| [solr](https://github.com/dokku/dokku-solr)                   | 1.24.0  |
| [typesense](https://github.com/dokku/dokku-typesense)         | 1.5.0   |

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

### New APIs for community plugins

Two plugins were added to Dokku Pro's HTTP API. API Support for Dokku features
generally comes first, while later releases will include changes to the Web UI
to include these additions.

#### API support for the community HTTP Auth Plugin

Authentication comes in many forms, and while most apps have this built-in,
simpler, pre-packaged applications may not. Dokku Pro introduces support for the
community [http-auth](https://github.com/dokku/dokku-http-auth) plugin, with
full API support for managing both user-based and IP-based access controls. This
comes with documentation in our included Swagger UI.

A future release of Dokku Pro will include a section in the UI for managing
network components for apps, including HTTP Auth support.

#### API support for the community HTTP Auth Plugin

In addition to authentication requirements, it may be necessary to enable or
disable _all_ access to your application. The community
[maintenance](https://github.com/dokku/dokku-maintenance) plugin provides the
ability to do just that.

In this release, we've added the ability to enable or disable maintenance mode
via API, fully-documented within our included Swagger UI. A future release of
Dokku Pro will include a section in the UI for managing network components for
apps, including setting apps in maintenance mode.

### Add ability to set the builder on a per-app basis

We've added the ability to set an app builder on a per-app basis. This
automatically picks up the following builders (if installed) and displays them
for selection:

- dockerfile
- docker-compose
- herokuish
- lambda
- nix
- null
- pack

<figure markdown>
  ![Builder Selection](/blog/assets/images/release-1.2.0/builder-selection.png){ width="500" }
  <figcaption>Selection a non-standard builder</figcaption>
</figure>

It is also possible to set a custom build directory in the same UI.

<figure markdown>
  ![Builder Selection](/blog/assets/images/release-1.2.0/build-dir-input.png){ width="500" }
  <figcaption>Selection a non-standard builder</figcaption>
</figure>

Both of these include API access, documented in our included Swagger UI.

### Team Management

Access control is a complex topic, and one Dokku has traditionally shied away
from. Dokku does not have a traditional user model, and it associates a simple
name to each ssh-key that a user uses to interact with the CLI over SSH. Until
recently, the only way to limit access was by installing the community
`dokku-acl` plugin and hoping it's rigid model for checking permissions aligned
with how you wanted to expose server access.

With Dokku Pro 1.2.0, there is now a flexible team-based model for access
control. System administrators can continue to access everything, but may create
teams with permissions against particular apps, services, and commands. Owners -
such as team leads or project managers - can be assigned to teams, delegating
access control for those teams to the folks closest to what those teams
represent. And finally, team members can perform the commands allowed by their
team permissions against the apps and services those teams control, and nothing
more.

The development of this feature required changes across the Dokku ecosystem.
New triggers were exposed in both service plugins as well as Dokku itself to
manage filtering of apps and services, while some plugins had to be updated in
order to respect the updated command system. Dokku Pro itself had several changes
to the permissioning system as it was designed and tested in real world settings.
While the initial intent was to release Dokku Pro much more often, the work
behind team management hopefully makes the wait worth it.

The initial release of team management is available via CLI commands. This
decision was made in order to release Dokku Pro sooner. A future release of
Dokku Pro will include API support for team management as well as Web UI
integration for managing teams.

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

#### Filtering apps in Dokku Pro

For some use-cases, it may be necessary to hide some apps from the Web UI and
API. In the case of Dokku's own installation of Dokku Pro, there are some
testing apps that have no value other than being placeholders for requests, and
thus are noise in the UI.

It is now possible to filter such apps from being accessible via Dokku Pro's
interface (they will still be available via CLI using normal `dokku` commands).
An `APPS_FILTER` environment variable can be set in the Dokku config with a
comma-delimited list of apps to hide. These apps will be hidden from API
responses and the Web UI as a result.

Checkout the [configuration documentation](/docs/operating/configuration/) for
more information on this new setting.

#### Ability to override the default root username

While the password for authentication is configurable, the `root` username was
not. An `ROOT_USERNAME` can be set in the Dokku config to override the default
`root` username. You can now login as the `lollipop` user if desired.

Checkout the [configuration documentation](/docs/operating/configuration/) for
more information on this new setting.

#### Typesense service support

Support for the new [typesense](https://github.com/dokku/dokku-typesense) plugin
has been added to services in Dokku. Users can expect the same functionality
they would from other services in Dokku, including complete support in our API,
Swagger UI documentation, and exposure in the Web UI.

New services will be added to future Dokku Pro releases as they are made
available.

#### Version checking for server commands

As mentioned above, we now check for specific versions of Dokku and installed
plugins on start of the Dokku Pro server. Users wishing to use supported plugins
that do not have at least the minimum version specified will have Dokku Pro fail
to boot with an error message detailing the problem.

Please be sure to keep up to date with the latest and greatest versions of Dokku
and any plugins you use.

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

#### Enhanced output for the config command

When running the `dokku-pro config` command, we previously hardcoded how certain
config was output. This has been refactored in such a way that we no longer
need to update the config command when adding new configuration properties.

#### Fix log formatting

Log output was a bit broken for the help and version commands, and elsewhere.
Dokku Pro now will only log in JSON format when there is no TTY - for example,
when running under `systemd` - and will have human-readable output otherwise

Additionally, we now use a single logging mechanism across the codebase, ensuring
most - if not all - logs are in the proper format, regardless of where the log
call is created.

#### Ignoring compiled assets during project search

This was actually a fairly painful issue, workflow-wise. Searching for instances
of code during refactoring was made painful due to including compiled assets,
binary files, and external dependencies. These are now ignored so the editor does
not lock up when searching for a random bit of javascript :)

#### Standardized code initialization

Previously, Dokku Pro would set up certain checks and load config on-the-fly.
This led to race conditions in certain cases, and was messier to understand.
All initialization code has now been placed in a central location that is easy
to understand when first diving into the code.

## Dokku Pro Pricing

With a new release comes a price increase. Although it was mentioned in the
1.1.0 release post, we previously avoided a price increase to give folks more
time to consider supporting Dokku Pro development at a lower price point. With
the new functionality, we believe it is time to start the increases. Dokku Pro's
price will continue to increase over time by various amounts until the product
settles to a more "feature-complete" state.

Please bear in mind that this is a lifetime license, and users are entitled to
all upgrades of Dokku Pro as long as they are made. Folks wishing to support
continued development of the project are encouraged to purchase today before the
price is increased.

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

## Coming up next?

Here is what we'll be working towards over the next few releases

- API and Web UI support for team management
- Improvements to service UI interactions
- Exposing HTTP Auth and Maintenance mode in the Web UI
- Alternative forms of authentication
- More APIs for core Dokku functionality!
- Persistent Storage management

As always, the roadmap is always subject to change, pending time constraints but
mostly feature requests by those who have purchased Dokku Pro. Have a feature
request or bug complaint? Feel free to file it in the issue tracker
[here](https://github.com/dokku/dokku-pro-issues/issues).

Thanks everyone for there support during this endeavor, and I hope you all enjoy
this release of Dokku Pro!
