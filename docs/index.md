---
template: main.html
title: Blog
search:
  exclude: true
---

<style>
  /*hide the duplicate blog heading*/
  .md-nav__item--nested .md-nav__item--active .md-nav__link:first-of-type {
    display:  none;
  }
  /*drop icon*/
  .md-nav__link .md-nav__icon.md-icon {
    display:  none;
  }
  .md-sidebar--secondary:not([hidden]) {
    visibility: hidden;
  }
  /*remove padding on blog posts*/
  .md-nav__item--nested .md-nav__item--nested .md-nav .md-nav__list .md-nav__item {
    padding:  0;
  }
</style>

# Blog

## [Release 1.2.0]

__The 1.2.0 release introduces team-based access control and many internal
refactors aimed at easing future development of the product.__

---

Dokku has traditionally been a single-tenant PaaS solution, where all users
had access to all functionality on the server. While there were community
plugins that tackled authentication, each implementation had it's rough edges due
to interfaces in Dokku itself. Dokku Pro 1.2.0 polishes those edges while
introducing a flexible permission system for organizations that need it.

  [:octicons-arrow-right-24: Continue reading][Release 1.2.0]

  [Release 1.2.0]: 2022/pro-release-1.2.0.md

## [Release 1.1.0]

__The 1.1.0 release is the first substantive update to Dokku Pro, and it brings
with it great changes around usability and functionality.__

---

Dokku Pro was released in late 2021 to early bird users willing to deal with a
bit of pain in exchange for supporting the project and vision. While it
technically worked, there were quite a few places for easy improvement, as well
as obvious holes in the existing functionality. Dokku Pro 1.1.0 aims to fill
some of those needs, laying the groundwork for future enhancements

  [:octicons-arrow-right-24: Continue reading][Release 1.1.0]

  [Release 1.1.0]: 2022/pro-release-1.1.0.md
