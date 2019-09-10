#!/usr/bin/env bash

if ! hadolint ./*Dockerfile*; then
  >&2 printf "Failed linting on Dockerfile\n"
  exit 1
fi

if ! shellcheck ./*.sh*; then
  >&2 printf "Failed shellchecking\n"
  exit 1
fi

if [ ! "$IGNORE_BUILD" ] && ! NO_CACHE=true NO_PUSH=true ./build.sh; then
  >&2 printf "Failed building image\n"
  exit 1
fi
