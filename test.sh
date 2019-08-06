#!/usr/bin/env bash

if ! hadolint ./*Dockerfile*; then
  echo "Failed linting on Dockerfile"
  exit 1
fi
if ! shellcheck ./*.sh*; then
  echo "Failed shellchecking"
  exit 1
fi

dv="$(docker version | grep "^ Version")"
dv="${dv#*:}"
dv="${dv##* }"
if [ "${dv%%.*}" != "19" ]; then
  echo "Docker is too old and doesn't support buildx. Ignoring build test."
  exit
fi

if ! NO_CACHE=true NO_PUSH=true ./build.sh; then
  echo "Failed building image"
  exit 1
fi
