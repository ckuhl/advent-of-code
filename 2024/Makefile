.DEFAULT_GOAL=help

.venv: ## Install dependencies
	uv sync

.PHONY: clean format help lint setup test

clean:  ## Remove development environment
	rm -rf .ruff_cache .venv/

format: .venv  ## Format code and automatically fix fixable lint issues
	uv run ruff check --fix
	uv run ruff format

lint: .venv  ## Lint using ruff
	uv run ruff check

test: .venv  ## Run all tests (i.e. Advent of Code solutions)
	uv run python -m unittest *.py

help:  ## Print this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
