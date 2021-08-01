package scullery

import (
  "tool/exec"
  "tool/os"
  "strings"
)

#Oven: {
	cake: #Cake

	no_cache: bool
	progress: string
	let _nc=no_cache
	let _pr=progress

	cake: _buildkit: no_cache: _nc
	cake: _buildkit: progress: _pr

  _tmp: os.Getenv & {TMPDIR: string | * "/tmp"}
  _tmp_dir: exec.Run & {
    prefix: string | * "dbdbdp"
    cmd: ["mktemp", "-dq", _tmp.TMPDIR + "/\(prefix).XXXXXX"] // XXX -> "||", "mktemp", "-q"]
    stdout: string
  }

  _sec_path: strings.TrimSpace(_tmp_dir.stdout) + "/SECRET_"

  cake: _buildkit: secret_path: _sec_path

	for _k, _v in cake._buildkit.secrets {
		if _v.content != _|_ {
	  // XXX multi file write is broken in cue 0.3 beta6, so... do it the hard way
    	"_process_secrets_\(_k)": exec.Run & {
      	stdin: _v.content
      	cmd: ["tee", _sec_path + _k]
      	stdout: string
      	$after: _tmp_dir
    	}
		}
		if _v.file != _|_ {
    	"_process_secrets_\(_k)": exec.Run & {
      	cmd: ["cp", _v.file, _sec_path + _k]
      	stdout: string
      	$after: _tmp_dir
    	}
		}
	}

	// If we have a root from where to read from, use it
	if cake.recipe.input.root != _|_ {
		cmd_license: exec.Run & {
			cmd: ["bash", "-c", #"""
			set -o errexit -o errtrace -o functrace -o nounset -o pipefail

			root="$1"
			[ ! -e "$root/LICENSE" ] || head -n 1 "$root/LICENSE"

			"""#, "--", cake.recipe.input.root]
			stdout: string
		}

		cmd_date: exec.Run & {
			cmd: ["bash", "-c", #"""
			set -o errexit -o errtrace -o functrace -o nounset -o pipefail

			root="$1"
			# XXX it doesn't seem like BSD date can format the timezone appropriately according to RFC3339 - eg: %:z doesn't work and %z misses the colon, so the gymnastic here
			# https://tools.ietf.org/html/rfc3339
			#DATE="$(date +%Y-%m-%dT%T%z | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/')"
			# This is last commit date - a much better date actually...
			date -r "$(git -C "$root" log -1 --format="%at")" +%Y-%m-%dT%T%z 2>/dev/null || date --date="@$(git -C "$root" log -1 --format="%at")" +%Y-%m-%dT%T%z | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/'

			"""#, "--", cake.recipe.input.root]
			stdout: string
		}

		cmd_version: exec.Run & {
			cmd: ["bash", "-c", #"""
			set -o errexit -o errtrace -o functrace -o nounset -o pipefail

			root="$1"
			git -C "$root" describe --match 'v[0-9]*' --dirty='.m' --always --tags

			"""#, "--", cake.recipe.input.root]
			stdout: string
		}

		cmd_revision: exec.Run & {
			cmd: ["bash", "-c", #"""
			set -o errexit -o errtrace -o functrace -o nounset -o pipefail

			root="$1"
			echo "$(git -C "$root" rev-parse HEAD)$(if ! git -C "$root" diff --no-ext-diff --quiet --exit-code; then printf ".m\\n"; fi)"

			"""#, "--", cake.recipe.input.root]
			stdout: string
		}

		cmd_url: exec.Run & {
			cmd: ["bash", "-c", #"""
			set -o errexit -o errtrace -o functrace -o nounset -o pipefail

			root="$1"
			git -C "$root" remote get-url origin | sed -E 's,.git$,,' | sed -E 's,^[a-z-]+:([^/]),https://github.com/\1,'

			"""#, "--", cake.recipe.input.root]
			stdout: string
		}

		cake: recipe: metadata: licenses: strings.TrimSpace(cmd_license.stdout)
		cake: recipe: metadata: created: strings.TrimSpace(cmd_date.stdout)
		cake: recipe: metadata: version: strings.TrimSpace(cmd_version.stdout)
		cake: recipe: metadata: revision: strings.TrimSpace(cmd_revision.stdout)
		cake: recipe: metadata: url: strings.TrimSpace(cmd_url.stdout)
	}

	_dependencies: [for _k, _v in cake._buildkit.secrets {
		"_process_secrets_\(_k)"
	}] + [_tmp_dir]

	run: exec.Run & {
    // XXX sleep 1 is horrific, but necessary to ensure files are being written (the _dependencies are not sufficient it seems)
  	cmd: ["bash", "-c", #"""
    set -o errexit -o errtrace -o functrace -o nounset -o pipefail
    echo ------------------------------------------------------------------
    wasTag=
    for i in "$@"; do
      if [ "${i:0:2}" == -- ]; then
      	if [ "$wasTag" ]; then
      		>&2 printf "\n"
      	fi
        wasTag=true
        >&2 printf " %s" "$i"
      else
      	wasTag=
        >&2 printf " %s\n" "$i"
      fi
    done
    echo ------------------------------------------------------------------
    sleep 1
    "$@"
    """#, "--"] + cake._buildkit.run
    $after: _dependencies
	}
}
