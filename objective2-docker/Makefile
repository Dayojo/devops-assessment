.PHONY: up down logs ps build clean restart

## Start the full stack (build if needed)
up:
	docker compose up -d --build

## Tear down the stack (keep volumes)
down:
	docker compose down

## Tear down and delete all volumes
clean:
	docker compose down -v --remove-orphans

## Tail logs for all services
logs:
	docker compose logs -f

## Show container status
ps:
	docker compose ps

## Rebuild images without cache
build:
	docker compose build --no-cache

## Restart all services
restart:
	docker compose restart

## Print useful URLs
urls:
	@echo ""
	@echo "  App         →  http://localhost:8000"
	@echo "  Health      →  http://localhost:8000/health"
	@echo "  Version     →  http://localhost:8000/version"
	@echo "  cAdvisor    →  http://localhost:8080"
	@echo "  Prometheus  →  http://localhost:9090"
	@echo "  Grafana     →  http://localhost:3000  (admin / devops2024)"
	@echo ""
