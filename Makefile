.PHONY: build test lint run tidy clean

BIN := bin/vibe
PKG := ./cmd/vibe
VERSION ?= 0.0.0-dev

build: ## Build the vibe CLI
	go build -ldflags "-X main.version=$(VERSION)" -o $(BIN) $(PKG)

test: ## Run all tests
	go test ./...

lint: ## Run golangci-lint (install: https://golangci-lint.run)
	golangci-lint run

run: build ## Build then run (use ARGS="detect ./app")
	$(BIN) $(ARGS)

tidy: ## Sync go.mod/go.sum
	go mod tidy

clean: ## Remove build artifacts
	rm -rf bin
