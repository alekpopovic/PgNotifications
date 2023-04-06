include .env

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## dev: run the src application
.PHONY: dev
dev:
	air

## db/psql: connect to the database using psql
.PHONY: db/psql
db/psql:
	psql ${DB_DSN}

## db/migrate/new name=$1: create a new database migration
.PHONY: db/migrate/new
db/migrate/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrate/up: apply all up database migrations
.PHONY: db/migrate/up
db/migrate/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${DB_DSN} up

## db/migrate/down: apply all up database migrations
.PHONY: db/migrate/down
db/migrate/down: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${DB_DSN} down

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy and vendor dependencies and format, vet and test all code
.PHONY: audit
audit: vendor
	@echo 'Formatting code...'
	go fmt ./src
	@echo 'Vetting code...'
	go vet ./src
	@echo 'Running tests...'
	go test -race -vet=off ./src

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build: build the src application
.PHONY: build
build:
	@echo 'Building src...'
	go build -ldflags="-s" -o=./bin/src ./src
	GOOS=linux GOARCH=amd64 go build -ldflags="-s" -o=./bin/linux_amd64/src ./src
