# ==============================
# Orbit — Makefile
# ==============================

.PHONY: help dev-up dev-down run-api run-worker build test lint fmt \
        migrate-up migrate-down migrate-status sqlc-generate \
        fe-dev fe-build fe-lint fe-test

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Entorno de desarrollo ---

dev-up: ## Levanta servicios de desarrollo (Docker Compose)
	docker compose up -d

dev-down: ## Detiene servicios de desarrollo
	docker compose down

# --- Backend ---

run-api: ## Ejecuta el servidor API
	go run ./cmd/api

run-worker: ## Ejecuta el worker
	go run ./cmd/worker

build: ## Compila binarios del servidor y worker
	go build -o bin/api ./cmd/api
	go build -o bin/worker ./cmd/worker

test: ## Ejecuta tests de Go
	go test ./...

lint: ## Ejecuta análisis estático (go vet)
	go vet ./...

fmt: ## Formatea código Go
	gofmt -w cmd internal

# --- Base de datos ---

migrate-up: ## Aplica migraciones pendientes
	@echo "Migration runner not yet configured (see C07)"

migrate-down: ## Revierte la última migración
	@echo "Migration runner not yet configured (see C07)"

migrate-status: ## Muestra estado de migraciones
	@echo "Migration runner not yet configured (see C07)"

sqlc-generate: ## Genera código desde consultas SQL
	@echo "sqlc not yet configured (see C08)"

# --- Frontend ---

fe-dev: ## Servidor de desarrollo frontend
	cd frontend && npm run dev

fe-build: ## Build de producción frontend
	cd frontend && npm run build

fe-lint: ## Lint de frontend
	cd frontend && npm run lint

fe-test: ## Tests de frontend
	cd frontend && npm test
