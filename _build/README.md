# blog build environment

Docker-based [mkdocs](https://www.mkdocs.org/) build environment for the Dokku blog.
Python dependencies are managed with [Poetry](https://python-poetry.org/) via
`pyproject.toml` and `poetry.lock`.

Run these from the repository root:

- `make docs-build-image` - build the `app/mkdocs-blog` image
- `make docs-build` - render the site into `blog/`
- `make docs-serve` - serve the site on http://localhost:3487
