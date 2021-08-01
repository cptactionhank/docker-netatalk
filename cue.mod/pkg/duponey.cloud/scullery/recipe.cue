package scullery

import (
	"duponey.cloud/buildkit/types"
)

#Recipe: {
	// Controls from what we are building:
	// - where is the context
	// - what is the root
	// - what dockerfile
	input: {
		root: types.#Path | * "./"
		context: types.#Path
		// XXX this is more likely something from the environment
		from: {
			registry?: string
			// XXXstart remove these once migration is finished
			runtime?: types.#Image
			builder?: types.#Image
			auditor?: types.#Image
			tools?: types.#Image
			// XXXend remove these once migration is finished
		}
		dockerfile?: types.#FilePath
		// XXX this should be an array
		// XXX this should be injectable
		// cache?: types.#CacheFrom
	}

	// Controls what we are going to process
	// - what platforms are we building
	// - what target inside the dockerfile
	// - what extra arguments do we want to pass
	// - and what extra secrets
	process: {
		platforms?: types.#Platforms
		target?: types.#Identifier
		// Backdoor into image specific arguments and secrets
		args: types.#Args
		secrets: types.#Secrets
	}

	// Controls the output:
	// - images to push
	// - directories
	// - tarballs
	output: {
		images?: {
			registries: {...},
			names: [...string],
			tags: [...string]
		}

		tags?: [...types.#Image]

		if images != _|_ {
			tags: [...types.#Image] | * [
				for _registry, _namespace in images.registries for _tag in images.tags for _name in images.names {
					types.#Image & {
						registry: _registry
						image: _namespace + "/" + _name
						tag: _tag
					},
				},
			]
		}
		directory?: types.#Path
		tarball?: types.#Tarball
		// XXX this should be an array
		// XXX this should be injectable
		// cache?: types.#CacheTo
	}

	// Metadata to attach to the image
	metadata: {
		created: string | * "1976-04-14"
		authors: =~ "^[^<]+ <[^>]+>$" | * "Dubo Dubon Duponey <dubo-dubon-duponey@farcloser.world>"
		url: types.#URL | *"https://github.com/dubo-dubon-duponey/unknown"
		documentation: types.#URL | *"\(url)/blob/master/README.md"
		source: types.#URL | *"\(url)/tree/master"
		version: string | *"unknown",
		revision: string | *"unknown",
		vendor: string | *"dubodubonduponey",
		licenses: string | *"MIT",
		ref_name: string | *"latest",
		title: string | *"Dubo Image",
		description: string | *"A long description for an intriguing Dubo image",
	}
}
