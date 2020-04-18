#!/usr/bin/env bash
#
# Verify that Circle CI config is valid.
#  - https://support.circleci.com/hc/en-us/articles/360006735753-Validating-your-CircleCI-Configuration
#  - https://circleci.com/docs/2.0/local-cli/
#
# For OSX you need to install the command-line client
#   brew install circleci
#
circleci config validate config.yml
