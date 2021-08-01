package scullery

import (
	"duponey.cloud/buildkit/types"
	"duponey.cloud/configurator"
	"strings"
)

#Scheme: {
	=~ "^(?:\(#HTTP)|\(#HTTPS)|\(#TLS)|\(#SSH)$"

	#HTTP: "http"
	#HTTPS: "https"
	#SSH: "ssh"
	#TLS: "tls"
}

#Host: {
	ip?: types.#IP

	[#Scheme]: {
		login?: types.#Login
		password?: types.#Password
		// XXX cannot have that in buildkit unfortunately - dynamic secrets...
		// certificate?: types.#Certificate
		// key?: types.#Key
		// keypass?: types.#Password
	}
}

#Subsystem: {
	proxy?: string // XXX suboptimal typing
	user_agent?: types.#UserAgent

	_configurator: configurator.#Configurator

	if proxy != _|_ {
		let _px=proxy
		_configurator: input: proxy: _px
	}
	if user_agent != _|_ {
		let _ua=user_agent
		_configurator: input: user_agent: _ua
	}
	...
}

#AptSubsystem: #Subsystem & {
	sources?: string
	check_valid?: bool

	_configurator: configurator.#APT

	if check_valid != _|_ {
		let _cv=check_valid
		_configurator: input: check_valid: _cv
	}
}

#CurlSubsystem: #Subsystem & {
	_configurator: configurator.#Curl
}

#Icing: {
	// XXX make this type more specific
	buildkit?: {
		address?: string | * "docker-container://buildkitd"
		name?: string
		ca?: types.#Path
		cert?: types.#Path
		key?: types.#Path
	}

	hosts: [types.#Domain]: #Host

	trust: {
		authority?: types.#Certificate
		gpg?: types.#FilePath
		certificate?: types.#Certificate
		// XXX THIS SEEMS like a horrific bug - using the #Key type silently mute anything referencing it
		key?: _ // was #Key
	}

	cache: {
		base?: types.#CacheFrom
	}

	subsystems: [string]: #Subsystem
	subsystems: apt: #AptSubsystem
	subsystems: curl: #CurlSubsystem
	subsystems: go?: #Subsystem
	subsystems: git?: #Subsystem
	subsystems: system?: #Subsystem

	secrets: [types.#Identifier]: types.#Secret

	// Assemble our secrets
	secrets: CERTIFICATE: types.#Secret
	secrets: KEY: types.#Secret
	secrets: APT_SOURCES: types.#Secret

	if trust.authority != _|_ {
		// secrets: CA: types.#Secret
		secrets: CA: content: trust.authority
		subsystems: apt: _configurator: input: authority: secrets.CA.path | * "/run/secrets/CA"
		subsystems: curl: _configurator: input: authority: secrets.CA.path | * "/run/secrets/CA"
	}
	if trust.gpg != _|_ {
		secrets: "GPG.gpg": file: trust.gpg
		// XXX for some reason, it does not inherit properly from properly defined secrets.GPG.path
		subsystems: apt: _configurator: input: trusted: secrets."GPG.gpg".path | * "/run/secrets/GPG.gpg"
	}

	let _netrc=strings.Join([
		for _k, _v in hosts if _v.https != _|_ if _v.https.login != _|_ {
			"machine \(_k) login \(_v.https.login) password \(_v.https.password)"
		}
	], "\n")

	if _netrc != "" {
		secrets: NETRC: content: _netrc
		subsystems: apt: _configurator: input: netRC: secrets.NETRC.path | * "/run/secrets/NETRC"
		subsystems: curl: _configurator: input: netRC: secrets.NETRC.path | * "/run/secrets/NETRC"
	}

	if subsystems.apt.sources != _|_ {
		secrets: APT_SOURCES: content: subsystems.apt.sources
 		subsystems: apt: _configurator: input: sources: secrets.APT_SOURCES.path | * "/run/secrets/APT_SOURCES"
	}

	// Bind into the configurators what has to be
	if trust.certificate != _|_ {
		secrets: CERTIFICATE: content: trust.certificate
		subsystems: apt: _configurator: input: certificate: secrets.CERTIFICATE.path | *"/run/secrets/CERTIFICATE"
		subsystems: curl: _configurator: input: certificate: secrets.CERTIFICATE.path | * "/run/secrets/CERTIFICATE"
	}

	if trust.key != _|_ {
		secrets: KEY: content: trust.key
 		subsystems: apt: _configurator: input: key: secrets.KEY.path | * "/run/secrets/KEY"
		subsystems: curl: _configurator: input: key: secrets.KEY.path | * "/run/secrets/KEY"
	}

	subsystems: curl: _configurator: input: {
		// proxy_user: string

		if subsystems.curl.proxy != _|_ {
		// Get the domain part of the proxy
			_proxyed: strings.Split(subsystems.curl.proxy, ":")
			_scheme: _proxyed[0]
			_domain: strings.Replace(_proxyed[1], "/", "", -1)
		// Curl needs a bit of help with the proxy user
			if hosts[_domain][_scheme].login != _|_ {
				proxy_user: hosts[_domain][_scheme].login + ":" + hosts[_domain][_scheme].password
			}
		}
	}

	// XXX something happens if we test this
	// if subsystems.apt._configurator.output != "" {
		secrets: APT_CONFIG: content: subsystems.apt._configurator.output
		secrets: APT_CONFIG: path: _ | *"/run/secrets/APT_CONFIG"
	//}
	//if subsystems.curl._configurator.output != "" {
		// secrets: CURL_OPTIONS: content: subsystems.curl._configurator.output
		// secrets: CURL_OPTIONS: path: _ | *"/root/.curlrc"

		secrets: ".curlrc": content: subsystems.curl._configurator.output
		secrets: ".curlrc": path: _ | *"/run/secrets/.curlrc"

	//}
}
