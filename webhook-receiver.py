#!/usr/bin/env python3

from argparse import ArgumentParser
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class POSTRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        status_code = 200

        data = self.rfile.read1()
        try:
            data = json.loads(data)
            print('RECEIVED DATA:', data)
        except json.JSONDecodeError:
            print('RECEIVED DATA:', data.decode())
        except UnicodeDecodeError as ex:
            print('ERROR!', ex)
            status_code = 400

        self.send_response(status_code)
        self.end_headers()

parser = ArgumentParser()
parser.add_argument(
    '-p',
    '--port',
    type=int,
    default=8000
)
parser.add_argument(
    '-b',
    '--address',
    default='0.0.0.0',
    help='bind to this address (default: all interfaces)'
)

args = parser.parse_args()

server = HTTPServer((args.address, args.port), POSTRequestHandler)
print(f'Serving HTTP on {args.address} port {args.port} (http://{args.address}:{args.port}/) ...')
try:
    server.serve_forever()
except KeyboardInterrupt:
    print('\nKeyboard interrupt received, exiting.')
