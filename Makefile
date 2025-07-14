[reset]:
	docker compose down
	docker compose build
	docker compose up -d
	docker logs -f rustdesk-tailscale
