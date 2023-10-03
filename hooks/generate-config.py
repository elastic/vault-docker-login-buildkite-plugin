#!/usr/bin/env python3

from os import environ, path
import base64
import json
import logging as log
import sys

log.basicConfig(level=log.INFO, stream=sys.stderr)

config_file_path = sys.argv[1] if len(sys.argv) > 1 else path.join(path.expanduser('~'), '.docker', 'config.json')  
config = {}


if path.exists(config_file_path):
    try:
        with open(config_file_path, 'r') as f:
            config = json.load(f)
    except json.decoder.JSONDecodeError:
        log.error(f'%s is not valid JSON, overwriting with new content.' % config_file_path)
        config = {}

log.info(f'Adding container registry to Docker config: %s' % environ['HOSTNAME'])

with open(config_file_path, 'w') as f:
    if len(config) == 0:
        config = {
            'auths': {
                environ['HOSTNAME']: {
                    'auth': base64.b64encode(f"{environ['DOCKER_USERNAME']}:{environ['DOCKER_PASSWORD']}".encode('utf-8')).decode('utf-8')
                }
            }
        }
    else:
        config['auths'][environ['HOSTNAME']] = {
            'auth': base64.b64encode(f"{environ['DOCKER_USERNAME']}:{environ['DOCKER_PASSWORD']}".encode('utf-8')).decode('utf-8')
        }
    f.write(json.dumps(config, indent=4))
