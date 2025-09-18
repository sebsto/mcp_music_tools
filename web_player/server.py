#!/usr/bin/env python3
import http.server
import socketserver
import os
import json
import jwt
import time
from urllib.parse import urlparse

class QueueHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/queue':
            try:
                with open('./music_queue_control.json', 'r') as f:
                    data = f.read()
                # os.remove('./music_queue_control.json')
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(data.encode())
            except FileNotFoundError:
                self.send_response(404)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
        elif self.path == '/' or self.path == '/index.html':
            try:
                with open('./index.html', 'r') as f:
                    data = f.read()
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(data.encode())
            except FileNotFoundError:
                self.send_response(404)
                self.end_headers()
        elif self.path == '/app.js':
            try:
                with open('./app.js', 'r') as f:
                    data = f.read()
                self.send_response(200)
                self.send_header('Content-type', 'application/javascript')
                self.end_headers()
                self.wfile.write(data.encode())
            except FileNotFoundError:
                self.send_response(404)
                self.end_headers()
        elif self.path == '/token':
            try:
                with open('secrets.json', 'r') as f:
                    secrets = json.load(f)
                
                payload = {
                    'iss': secrets['teamId'],
                    'iat': int(time.time()),
                    'exp': int(time.time()) + (180 * 24 * 60 * 60)  # 180 days
                }
                headers = {'alg': 'ES256', 'kid': secrets['keyId']}
                token = jwt.encode(payload, secrets['privateKey'], algorithm='ES256', headers=headers)
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'token': token}).encode())
            except Exception as e:
                self.send_response(500)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                print(f"Token generation error: {e}")
        else:
            super().do_GET()

if __name__ == "__main__":
    PORT = 8000
    with socketserver.TCPServer(("", PORT), QueueHandler) as httpd:
        print(f"Server running at http://localhost:{PORT}")
        httpd.serve_forever()