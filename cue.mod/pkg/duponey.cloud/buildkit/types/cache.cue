package types

import (
	"strings"
)

#CacheMode: {
	string
  =~ "^(?:\(#MAX)|\(#MIN))$"

  #MIN: "min"
  #MAX: "max"
}

#CacheType: {
	string
	// XXX CUE WTF - WHY WHY WHY WHY
	=~ "^(?:\(#INLINE)|\(#REGISTRY)|\(#LOCAL))$"
	// #INLINE | #REGISTRY | #LOCAL

  #LOCAL: "local"
  #INLINE: "inline"
  #REGISTRY: "registry"
}

#CacheTo: {
	type: #CacheType
	toString: string

	// disjunction of structs will ignore default values...
	if type == #CacheType.#INLINE {
		// XXX Not ideal - should find a way to prevent them having a value (eg: they should bottom in that case)
		// location:
		// mode:
		toString: "type=\(type)"
	}
	if type == #CacheType.#REGISTRY {
		location: #Image
	  oci: bool | *true
	  mode: #CacheMode | *#CacheMode.#MAX
		toString: "type=\(type),ref=\(location.toString),mode=\(mode),oci-mediatypes=\(oci)"
	}
	if type == #CacheType.#LOCAL {
		location: #Path
	  oci: bool | *true
	  mode: #CacheMode | *#CacheMode.#MAX
		toString: "type=\(type),dest=\(location),mode=\(mode),oci-mediatypes=\(oci)"
	}

	#fromString: string
	if #fromString != _|_ {
		let _d=strings.Split(#fromString, ",")
		for _k, _v in _d {
			if strings.Contains(_v, "=") {
				let _e=strings.Split(_v, "=")
				// supplemental: _e[1]
				if _e[0] == "ref" {
					location: #fromString: _e[1]
				}
				if _e[0] == "dest" {
					location: _e[1]
				}
				if _e[0] != "ref" && _e[0] != "dest" {
					"\(_e[0])": _e[1]
				}
			}
		}
	}
}

#CacheFrom: {
  type: #CacheType
	toString: string

	// Buildkit says: "Use registry to import inline cache"
	// XXX not sure how that works - not specify the ref?
	if type == #CacheType.#REGISTRY {
		location: #Image
		toString: "type=\(type),ref=\(location.toString)"
	}
	if type == #CacheType.#LOCAL {
		location: #Path
		// XXX digest and tag not implemented
		toString: "type=\(type),src=\(location)"
	}

	#fromString: string
	if #fromString != _|_ {
		let _d=strings.Split(#fromString, ",")
		for _k, _v in _d {
			if strings.Contains(_v, "=") {
				let _e=strings.Split(_v, "=")
				// supplemental: _e[1]
				if _e[0] == "ref" {
					location: #fromString: _e[1]
				}
				if _e[0] == "src" {
					location: _e[1]
				}
				if _e[0] != "ref" && _e[0] != "src" {
					"\(_e[0])": _e[1]
				}
			}
		}
	}
}
