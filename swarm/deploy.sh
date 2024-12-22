#!/bin/bash

stack=""
svc=""
deployment_dir=""
tag_image=""
host=""
tls="internal"
env_file=""

for arg in "$@"; do
  case $arg in
    stack=*)
      stack="${arg#*=}"
      shift
      ;;
    svc=*)
      svc="${arg#*=}"
      shift
      ;;
    deployment_dir=*)
      deployment_dir="${arg#*=}"
      shift
      ;;
    tag_image=*)
      tag_image="${arg#*=}"
      shift
      ;;
    host=*)
      host="${arg#*=}"
      shift
      ;;
    tls=*)
      tls="${arg#*=}"
      shift
      ;;
    env_file=*)
      env_file="${arg#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

# Check if the variables are set

if [ -z "$stack" ]; then
  echo "stack is required"
  exit 1
fi

if [ -z "$svc" ]; then
  echo "svc is required"
  exit 1
fi

if [ -z "$deployment_dir" ]; then
  echo "deployment_dir is required"
  exit 1
fi

if [ -z "$tag_image" ]; then
  echo "tag_image is required"
  exit 1
fi

if [ -z "$host" ]; then
  echo "host is required"
  exit 1
fi

# Deploy the stack

yaml_content=$(cat "$deployment_dir/$svc.template.yml")

# envs

if [ -f "$env_file" ]; then
  while IFS='=' read -r key value; do
    if [[ -n "$key" && -n "$value" && "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
      export "$key=$value" > /dev/null 2>&1
    fi
  done < <(grep -v '^#' "$env_file")
else
  while IFS='=' read -r key value; do
    if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && -n "$value" ]]; then
      export "$key=$value" > /dev/null 2>&1
    fi
  done < <(env)
fi

for var in $(env | grep '^DEPLOY_'); do
  IFS='=' read -r key value <<< "$var"
  cleaned_key="${key#DEPLOY_}"

  yaml_content=$(echo "$yaml_content" | yq eval ".services.$stack-$svc.environment += [\"$cleaned_key=$value\"]")
done

# Replace the placeholders with the actual values
yaml_content=$(echo "$yaml_content" | sed "s/TAG_PLACEHOLDER/$tag_image/g")
yaml_content=$(echo "$yaml_content" | sed "s/HOST_PLACEHOLDER/$host/g")
yaml_content=$(echo "$yaml_content" | sed "s/TLS_PLACEHOLDER/$tls/g")

echo "$yaml_content"
