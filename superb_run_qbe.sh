#!/usr/bin/env bash

# set arguments
NAME="$1"
UPSTREAM="$2"
UPSTREAM_PATH="$3"
LAYER_NUM="$4"

# run command
just downstream::query-by-example-spoken-term-detection "$NAME" "$UPSTREAM" "$UPSTREAM_PATH" "$LAYER_NUM"