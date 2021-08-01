package types

import (
	"strings"
)

#_GRAMMAR_ALPHANUM: "[a-z0-9]+"
#_GRAMMAR_SEP: "(?:[._]|__|[-]*)"
#_GRAMMAR_NAME: "^\(#_GRAMMAR_ALPHANUM)(?:\(#_GRAMMAR_SEP)\(#_GRAMMAR_ALPHANUM))*(?:/\(#_GRAMMAR_ALPHANUM)(?:\(#_GRAMMAR_SEP)\(#_GRAMMAR_ALPHANUM))*)*$"
#_GRAMMAR_TAG: "^[a-z0-9_][a-z0-9_.-]{0,127}$"
#_GRAMMAR_DIGEST: "^[a-z][a-z0-9]*(?:[-_+.][a-z][a-z0-9]*)*:[a-f0-9]{32,}$"
#_GRAMMAR_DIGEST_SHA256: "^sha256:[a-f0-9]{64}$"
#_GRAMMAR_TAG_DIGEST: "^(?:[a-z0-9_][a-z0-9_.-]{0,127}|sha256:[a-f0-9]{64})$"

// XXX State of cue:
// - struct disjunctions DO NOT respect default values, so, they are unusable here
// - builtins (strings.X) DO NOT respect default values, so, they are unusable here
// - there is some cycle detection that is looses its shite and forces us to nest our `ifs` under a BS `if` that always eval as true to workaround it
// - defaults from internal #Def makes things break in creative ways, so...
// All of this was an experiment: is there a way to create objects in cue that encapsulate their serialization / deserialization logic
// The answer is: I failed - while the tests work, this breaks in very confusing ways down the road
#Image: {
	registry: #Domain | #IP | * "docker.io" // #DOCKER
	image: =~ #_GRAMMAR_NAME | * "scratch" // #SCRATCH
	tag: =~ #_GRAMMAR_TAG | *""
	digest : =~ #_GRAMMAR_DIGEST | *""

	#LATEST: "latest"
	#DOCKER: "docker.io"
	#SCRATCH: "scratch"

	toString: string
	#fromString: string

	// Prevent re-entrancy
	_hasParsed: bool

	if #fromString != _|_ && _hasParsed == _|_ {
		_hasParsed: true
		// XXX cue forces you to have declared values
		_host_and_image: string

		_split_digest: strings.Split(#fromString, "@")
		if len(_split_digest) > 1 {
			digest: _split_digest[1]
		}

		_split_tag: strings.Split(_split_digest[0], ":")
		if len(_split_tag) > 1 {
			tag: _split_tag[1]
		}

		_split_host: strings.SplitN(_split_tag[0], "/", 2)
		// Prevent re-entrancy - XXX no way this can work, as defaults cannot be distinguished
		if strings.Contains(_split_host[0], ".") { // }&& registry == _|_ && image == _|_ {
			registry: _split_host[0]
			image: _split_host[1]
		}
		// Prevent re-entrancy, as defaults cannot be distinguished
		if ! strings.Contains(_split_host[0], ".") { // }&& image == "scratch" {
			image: _split_tag[0]
		}
	}

	_cue_this_is_horrific: _
	if _cue_this_is_horrific == _|_ {
		if registry =~ "^(.+[.])?docker[.]io$" && image == "scratch" {
			toString: "scratch"
		}
		if image != "scratch" || !(registry =~ "^(.+[.])?docker[.]io$") {
			if tag == _|_ || tag == "" {
				if digest == _|_ || digest == "" {
					toString: registry + "/" + image + ":latest"
				}
				if digest != _|_ && digest != "" {
					toString: registry + "/" + image + "@" + digest
				}
			}

			if tag != _|_ && tag != "" {
				if digest == _|_ || digest == "" {
					toString: registry + "/" + image + ":" + tag
				}
				if digest != _|_ && digest != "" {
					toString: registry + "/" + image + ":" + tag + "@" + digest
				}
			}
		}
	}
}
