package cake

import (
	"duponey.cloud/scullery"
	"duponey.cloud/buildkit/types"
)

// Adding injectors / tags that are always valid for all recipes, controlling specific aspects of buildkit behavior
_no_cache: *false | bool @tag(no_cache,type=bool)
_progress: *types.#Progress.#AUTO | string @tag(progress,type=string)

// Declare existing cakes as commands so that cue can exec them
for _k, _v in cakes {
	command: "\(_k)": scullery.#Oven & {
		cake: _v
		no_cache: _no_cache
		progress: _progress
	}
}
