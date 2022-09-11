---
template: blog.html
description: >
  Dokku Pro 1.1.0 brings Swagger support, Resource Scaling, and easier
  datastore service management
---

__The 1.1.0 release is the first substantive update to Dokku Pro, and it brings
with it great changes around usability and functionality.__

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

---

Dokku Pro was released in late 2021 to early bird users willing to deal with a
bit of pain in exchange for supporting the project and vision. While it
technically worked, there were quite a few places for easy improvement, as well
as obvious holes in the existing functionality. Dokku Pro 1.1.0 aims to fill
some of those needs, laying the groundwork for future enhancements.

Here are a few of the updates included in Dokku Pro 1.1.0.

## Major Changes

### This lovely docs site

We've added a more comprehensive documentation site for Dokku Pro. The
documentation will continue to improve and will always reference the latest
version of Dokku Pro (currently 1.1.0). Enjoy!

### Requires Dokku 0.27.0

The minimum Dokku version increase was made to ensure memory-scaling worked properly.
Users of older version of Dokku _may_ still have working installs, though memory
scaling will not work correctly for the `docker-local` scheduler.

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

### Minimum required datastore plugin versions

As a reminder, it is also recommended to update all datastore plugins to ensure
services are properly listed in the API and UI. In addition, the upgrades are
necessary for support for deferred app rebuilds during service linking. Without
them, service linking may time out.

Here are the versions necessary for this release of Dokku Pro:

| Plugin                                                        | Version |
| --------------------------------------------------------------|---------|
| [clickhouse](https://github.com/dokku/dokku-clickhouse)       | 0.13.3  |
| [couchdb](https://github.com/dokku/dokku-couchdb)             | 1.21.4  |
| [elasticsearch](https://github.com/dokku/dokku-elasticsearch) | 1.20.3  |
| [graphite](https://github.com/dokku/dokku-graphite)           | 1.18.2  |
| [mariadb](https://github.com/dokku/dokku-mariadb)             | 1.19.2  |
| [meilisearch](https://github.com/dokku/dokku-meilisearch)     | 0.2.1   |
| [memcached](https://github.com/dokku/dokku-memcached)         | 1.18.4  |
| [mongo](https://github.com/dokku/dokku-mongo)                 | 1.17.4  |
| [mysql](https://github.com/dokku/dokku-mysql)                 | 1.19.4  |
| [nats](https://github.com/dokku/dokku-nats)                   | 1.19.3  |
| [omnisci](https://github.com/dokku/dokku-omnisci)             | 1.19.1  |
| [postgres](https://github.com/dokku/dokku-postgres)           | 1.19.3  |
| [pushpin](https://github.com/dokku/dokku-pushpin)             | 0.9.1   |
| [rabbitmq](https://github.com/dokku/dokku-rabbitmq)           | 1.19.4  |
| [redis](https://github.com/dokku/dokku-redis)                 | 1.19.2  |
| [rethinkdb](https://github.com/dokku/dokku-rethinkdb)         | 1.17.2  |
| [solr](https://github.com/dokku/dokku-solr)                   | 1.19.4  |

To update, run:

```shell
# update the ``dokku-update` package first
sudo apt update
sudo apt install dokku-update

# update your install (skipping app rebuild)
sudo dokku-update run --skip-rebuild
```

### Add ability to link an app to a service

Users are now able to link apps to services. This required a ton of changes to
how datastores worked in the API, and the resulting refactor makes it much easier
to add new datastores to Dokku Pro.

To manage service links, go to the `Settings` section of a given app and use the
`Linked Services` subsection.

<figure markdown>
  ![Service Linking](/blog/assets/images/release-1.1.0/service-linking.png){ width="500" }
  <figcaption>UI for managing service links</figcaption>
</figure>

### Refactor datastore and service apis for easier expansion

In order to make service linking work, we required a few changes:

- exposing a single api for listing all available datastores
- simplifying how datastores are added/removed
- fixing certain endpoints that just plain didn't work

Dokku Pro 1.1.0 brings a simplified `/datastores` and `/services` api. The former
is used to interact with the datastore plugins as a whole - in the future, this
may even include setting global datastore plugin properties. The `/services`
endpoint now abstracts all instances of every datastore, bringing a single api
endpoint for querying and interacting with _all_ services installed on your
Dokku server. This makes it much simpler to support a new datastore - now a 2-line change -
versus the previous method of generating various files that still needed work to
plug into the api model layer.

These APIs are now considered stable for external use. Enjoy!

### Implement resource scaling ui

The initial release of Dokku Pro included process count scaling, but offered
nothing for container resources. New in 1.1.0, we added the ability to set
memory reservations.

<figure markdown>
  ![Resource Scaling](/blog/assets/images/release-1.1.0/memory-scaling.png){ width="500" }
  <figcaption>Memory scaling</figcaption>
</figure>

For this rough release, we've opted to avoid limits - so that containers can
burst on resource utilization - and have omitted CPU - as this is typically bursty
on single-instance Dokku installations. We'll be working on the UI in future
releases, and hope to include both memory _and_ CPU for limits and reservations
in a way that makes sense for our users.

See [this tweet thread](https://twitter.com/dokku/status/1490755087697858565) for
more details on how... interesting this functionality ended up.

### Add swagger support

An interactive Swagger UI for Dokku Pro is now available at the `/swagger` endpoint.
Users can also access the OpenAPI 3.0.1 spec at `/swagger/openapi.yml`.

<figure markdown>
  ![Swagger UI](/blog/assets/images/release-1.1.0/swagger.png){ width="500" }
  <figcaption>Integrated Swagger UI</figcaption>
</figure>

### Add ability to set the scheduler on a per-app basis

We've added the ability to set an app scheduler on a per-app basis. This
automatically picks up the following schedulers (if installed) and displays them
for selection:

- docker-local
- kubernetes
- nomad
- null

<figure markdown>
  ![Scheduler Selection](/blog/assets/images/release-1.1.0/scheduler-selection.png){ width="500" }
  <figcaption>Selection a non-standard scheduler</figcaption>
</figure>

## Minor Changes

#### Allow customizing the network dokku-pro listens on

If you are running Dokku Pro on a local network that doesn't have IPv6 support,
you can now set the `SERVER_NETWORK` configuration variable to `tcp4` to listen
only on IPv4.

#### Set higher default write timeout to allow for slow service creation calls to complete

The default server read and write timeouts were too low for certain tasks - notably
datastore creation and destruction - to complete in time, resulting in UI errors.
These are now configurable via `SERVER_READ_TIMEOUT` and `SERVER_WRITE_TIMEOUT`,
and also have higher default values. Folks on slower servers should see significant
improvement in their overall user experience.

#### Add cli command for outputting current dokku-pro settings

One annoying issue when debugging an installation is ensuring all the configuration
variables are set properly. Users can now run `dokku-pro config` to show a user-friendly
version of the current server config. This can be used to verify that the Dokku Pro
license and other configuration options are as you expect.

## UI Changes

#### Always use correct icon size for app status

The app status icon was sometimes too large. While big head mode is cool, its not
so much in a UI. We now use the correct image size.

#### Fix issue in ui when saving a domain for an app

Apps with no domains had issues saving an initial domain without using the CLI.
Since one of the goals of Dokku Pro is to supply a web UI, this seems a bit backwards.
You can now properly set domains for new apps!

#### Correct process type name in the scaling UI

The process scaling ui showed the app name instead of the process type. This made
no sense and was confusing for users with multiple process types.

#### Make the env/domains settings pages span the entire page

There was a minor change to the environment variable and domain setting pages that
made better use of the screen real estate.

### API Changes

#### Add meilisearch datastore plugin

Taking advantage of our new datastore plumbing, we added the [Meilisearch](https://github.com/dokku/dokku-meilisearch)
plugin to Dokku Pro.

#### Add better error messaging when validating api entities from composite keys

When interacting with entities that have composite primary keys - domains, environment
variables, formations - users would get somewhat opaque error messages. These
have been updated to include more detail.

#### Fix access to service relationships in the api

Services now come back as properly associated with apps, making many of the normal
json-api relationship endpoints work.

## Dokku Pro Pricing

Now that there is a new release of Dokku Pro, the early bird pricing will increase.
This was previously mentioned in various Dokku Pro announcements, but the price
will continue to increase by various amounts until the product settles.

Please bear in mind that this is a lifetime license, and users are entitled to
all upgrades of Dokku Pro as long as they are made. Folks wishing to support
continued development of the project are encouraged to purchase today before the
price is increased.

<a class="md-button" href="https://dokku.dpdcart.com/cart/add?product_id=217344&method_id=236878">Get your copy today</a>

## Coming up next?

The next milestone will continue to have many minor additions, with some effort
made on the following additions:

- HTTP Auth management
- Maintenance Mode management
- Persistent Storage management
- UI customizations (branding, push urls, hiding apps)
- Some form of multi-user support

As always, the roadmap is always subject to change, pending time constraints but
mostly feature requests by those who have purchased Dokku Pro. Have a feature
request or bug complaint? Feel free to file it in the issue tracker [here](https://github.com/dokku/dokku-pro-issues/issues).

Thanks everyone for there support during this endeavor, and I hope you all enjoy
this release of Dokku Pro!
