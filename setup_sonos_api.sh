#!/bin/bash

# Create a directory for the Sonos API
mkdir -p sonos-api

# Navigate to the directory
cd sonos-api

# Check if node-sonos-http-api is already cloned
if [ ! -d "node-sonos-http-api" ]; then
    echo "Cloning node-sonos-http-api..."
    git clone https://github.com/jishi/node-sonos-http-api.git
    cd node-sonos-http-api
    npm install
else
    echo "node-sonos-http-api already exists, updating..."
    cd node-sonos-http-api
    git pull
    npm install
fi

echo "Starting Sonos HTTP API server..."
echo "Press Ctrl+C to stop the server"
node server.js
