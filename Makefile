.PHONY: all lint test shellcheck clean

all: lint shellcheck test

test:
	-docker compose \
	  run --rm \
	  	-v "${PWD}:/app" \
	  	tests

lint:
	-docker compose run lint

shellcheck:
	-docker compose run shellcheck

clean:
	-docker compose \
		rm --force --stop
		