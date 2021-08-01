#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Get where we are
# shellcheck source=/dev/null
root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)/../"
readonly root

# Make sure we have our tools in place
# shellcheck source=/dev/null
. "$root"/hack/setup.sh

# Ignore some hadolint warnings that do not make much sense
# DL3006 is about "dO nOT UsE --platform", which is really ludicrous
# DL3029 complains about unpinned images (which is not true, we are just using ARGs for that)
# DL4006 is about setting pipefail (which we do, in our base SHELL)
# DL3059 is about not having multiple successive RUN statements, and this is moronic
# SC2039 is about array ref in POSIX shells (we are using bash, so)
# SC2027 is about quotes inside quotes, and is moronic too
readonly hadolint_ignore=(--ignore DL3006 --ignore DL3029 --ignore DL4006 --ignore DL3059 --ignore SC2039 --ignore SC2027)

if ! hadolint "${hadolint_ignore[@]}" "$root"/*Dockerfile*; then
  printf >&2 "Failed linting on Dockerfile\n"
  exit 1
fi

if ! shellcheck "$root"/**/*.sh; then
  printf >&2 "Failed shellchecking\n"
  exit 1
fi
