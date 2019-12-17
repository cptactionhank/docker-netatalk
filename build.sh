#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

export TITLE="Netatalk"
export DESCRIPTION="A dubo image for Netatalk"
export IMAGE_NAME="netatalk"

# shellcheck source=/dev/null
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)/helpers.sh"
