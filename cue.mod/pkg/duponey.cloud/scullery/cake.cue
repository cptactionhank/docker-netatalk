package scullery

import (
	"duponey.cloud/buildkit/buildctl"
	"duponey.cloud/buildkit/types"
)

#Cake: {
	// Takes image definition and user defined inputs
	recipe: #Recipe
	icing: #Icing
	hosts: types.#Hosts // [string]: string

	// XXXWIP
	// injector: #Injector
	//for _k, _v in injector {
	//	_buildkit: "\(_k)": _v
	//}
	// XXX

	// Instanciate subsystems and populate them
	_buildkit: buildctl.#Commander

	// Connect the image definitions into buildkit (XXX and inject overrides?)
	_buildkit: {
		addr: icing.buildkit.address
		tls: {
			name : icing.buildkit.name
			ca : icing.buildkit.ca
			key : icing.buildkit.key
			cert : icing.buildkit.cert
		}
		// XXX this does not work as expected, and is one of the most aggravating things about cue - the inability to have cascading defaults resolve to something (especially with @tags)
		// If no context was provided at all, default to ./context for buildkit - this means that none of the scullery tooling can operate safely on the value of the context - fine
    context: string | * "./context"
    context: recipe.input.context
    if recipe.input.dockerfile != _|_ {
			filename: recipe.input.dockerfile
		}

    if recipe.output.directory != _|_ {
    	directory: recipe.output.directory
    }
    if recipe.process.platforms != _|_ {
	    platforms: recipe.process.platforms
    }
    if recipe.process.target != _|_ {
    	target: recipe.process.target
    }
    if recipe.output.tags != _|_ {
	    tags: recipe.output.tags
    }
		//if icing.cache.from != _|_ {
		//	cache_from: icing.cache.from
		//}
		//if icing.cache.to != _|_ {
		//	cache_to: icing.cache.to
		//}
		if icing.cache.base != _|_ {
			cache_from: icing.cache.base
			cache_to: types.#CacheTo & {
				type: icing.cache.base.type
				location: icing.cache.base.location
			}
		}
		args: recipe.process.args

		// Making these standard for now
    args: {
    	// This is sui generis
    	if recipe.input.from.registry != _|_ {
	    	FROM_REGISTRY: recipe.input.from.registry,
    	}

			// XXXstart remove this when done migrating
    	if recipe.input.from.runtime.toString != _|_ {
    		FROM_IMAGE_RUNTIME: recipe.input.from.runtime.toString,
    	}
    	if recipe.input.from.builder.toString != _|_ {
	    	FROM_IMAGE_BUILDER: recipe.input.from.builder.toString,
    	}
    	if recipe.input.from.tools.toString != _|_ {
	    	FROM_IMAGE_TOOLS: recipe.input.from.tools.toString,
    	}
    	if recipe.input.from.auditor.toString != _|_ {
	    	FROM_IMAGE_AUDITOR: recipe.input.from.auditor.toString,
    	}
			// XXXend remove this when done migrating

			BUILD_TITLE: recipe.metadata.title
			BUILD_DESCRIPTION: recipe.metadata.description
			BUILD_CREATED: recipe.metadata.created
			BUILD_URL: recipe.metadata.url
			BUILD_LICENSES: recipe.metadata.licenses
			BUILD_VERSION: recipe.metadata.version
			BUILD_REVISION: recipe.metadata.revision

			BUILD_DOCUMENTATION: recipe.metadata.documentation
			BUILD_SOURCE: recipe.metadata.source
			BUILD_VENDOR: recipe.metadata.vendor
			BUILD_REF_NAME: recipe.metadata.ref_name
    }

		// XXX not really the right location for that - also suppose that an arg named GOPROXY exist, which is a problem - maybe secret instead?
		// and/or maybe a proper subsystem that would control go env overall?
		if icing.subsystems.go.proxy != _|_ {
			args: GOPROXY: icing.subsystems.go.proxy
		}

		for _k, _v in icing.hosts {
			if _v.ip != _|_ {
				hosts: "\(_k)": _v.ip
			}
		}

		secrets: icing.secrets
		secrets: recipe.process.secrets
	}

	// buildkit: _buildkit
	// apt: _apt
	// curl: _curl
}
