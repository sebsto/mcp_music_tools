# Makefile for AppleMusicTool and SonosTool

.PHONY: list-apple list-sonos call-apple call-sonos

start-sonos: 
	./setup_sonos_api.sh

list-apple:
	echo '{"jsonrpc": "2.0","id": 1,"method": "tools/list"}' | swift run AppleMusicTool

list-sonos:
	echo '{"jsonrpc": "2.0","id": 1,"method": "tools/list"}' | swift run SonosTool

list-amplifier:
	echo '{"jsonrpc": "2.0","id": 1,"method": "tools/list"}' | swift run AmplifierTool

call-apple:
	cat data/apple_music_call.json | swift run AppleMusicTool

call-sonos:
	cat data/sonos_call.json | swift run SonosTool

call-amplifier:
	cat data/amplifier_call.json | swift run AmplifierTool

run:
	swift run -Xswiftc -diagnostic-style=llvm BedrockCLI --temp-credentials-path ~/temp_credentials.json 

trace:
	swift run -Xswiftc -diagnostic-style=llvm BedrockCLI --log-level trace --temp-credentials-path ~/temp_credentials.json

format:
	swift format format --parallel --recursive --in-place ./Package.swift Examples/ Sources/ Tests/
