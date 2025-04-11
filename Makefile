# Makefile for AppleMusicTool and SonosTool

.PHONY: list-apple list-sonos call-apple call-sonos

start-sonos: 
	./setup_sonos_api.sh

list-apple:
	echo '{"jsonrpc": "2.0","id": 1,"method": "tools/list"}' | swift run AppleMusicTool

list-sonos:
	echo '{"jsonrpc": "2.0","id": 1,"method": "tools/list"}' | swift run SonosTool

call-apple:
	cat apple_music_call.json | swift run AppleMusicTool

call-sonos:
	cat sonos_call.json | swift run SonosTool
