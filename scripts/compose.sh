#!/bin/bash

# Check if at least 1 argument is provided (action)
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <action (up or down)> [additional flags]"
  exit 1
fi

# Assign arguments to variables
ACTION=$1
FLAGS=${@:2} # All additional arguments starting from the 2nd

# Execute the Docker Compose command
# Check if flags are provided and pass them if they are
if [ -z "$FLAGS" ]; then
  docker compose -f ./docker/testing/compose.yml --env-file .env "$ACTION"
else
  docker compose -f ./docker/testing/compose.yml --env-file .env "$ACTION" $FLAGS
fi
