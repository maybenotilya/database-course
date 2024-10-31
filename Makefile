up:
	@docker compose down
	docker compose up -d --force-recreate

stop:
	docker compose stop