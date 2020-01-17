#!/usr/bin/env bash
echo ""
set -e
config=docker-compose.yml
docker-compose -f ${config} rm --force && docker-compose -f ${config} up --build
