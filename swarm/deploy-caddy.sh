#!/bin/bash

# Deploy Caddy

tls=""
timezone="America/Cancun"
deployment_dir=""

for arg in "$@"; do
  case $arg in
    tls=*)
      tls="${arg#*=}"
      shift
      ;;
    timezone=*)
      timezone="${arg#*=}"
      shift
      ;;
    deployment_dir=*)
      deployment_dir="${arg#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

if [ -z "$tls" ]; then
  echo "tls is required"
  exit 1
fi

if [ -z "$deployment_dir" ]; then
  echo "deployment_dir is required"
  exit 1
fi

# Create network

existNetwork=$(docker network ls --filter name=caddy -q)

if [ -z "$existNetwork" ]; then
  docker network create --driver overlay caddy > /dev/null
fi

# Replace placeholders in the template

yaml_content=$(cat "$deployment_dir/caddy.template.yml")

yaml_content=$(sed -e "s|TLS_PLACEHOLDER|$tls|g" -e "s|TIMEZONE_PLACEHOLDER|$timezone|g" <<< "$yaml_content")

echo "$yaml_content"