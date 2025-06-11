.PHONY: all lint pre-commit test shellcheck clean

all: lint pre-commit shellcheck test

test:
	-docker compose \
	  run --rm \
	  	-v "${PWD}:/app" \
	  	tests

lint:
	-docker compose run lint

pre-commit:
	@echo "Running pre-commit"
	-.buildkite/scripts/pre-commit.sh

shellcheck:
	-docker compose run shellcheck

clean:
	-docker compose \
		rm --force --stop
