.PHONY: docs-build-image
docs-build-image:
	 docker build -f _build/Dockerfile --progress plain -t app/mkdocs-blog .

.PHONY: docs-build
docs-build:
	@docker run --rm -p 3487:3487 -v "$(PWD):/usr/src/source" --name blog-serve app/mkdocs-blog build

.PHONY: docs-serve
docs-serve:
	docker run --rm -p 3487:3487 -v "$(PWD):/usr/src/source" --name blog-serve app/mkdocs-blog serve

.PHONY: docs-deps
docs-deps:
	@docker run --rm -p 3487:3487 -v "$(PWD):/usr/src/app" app/mkdocs-blog deps

.PHONY: docs-enter
docs-enter:
	docker exec -it blog-serve bash
