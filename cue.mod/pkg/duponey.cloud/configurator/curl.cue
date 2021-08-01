package configurator

import (
	"duponey.cloud/types"
	"strings"
)

#Curl: #Configurator & {
	input: {
		user_agent?: types.#UserAgent
		proxy?: types.#URL
		authority?: types.#FilePath
		certificate?: types.#FilePath
		key?: types.#FilePath
		netRC?: types.#FilePath

		proxy_user?: string // XXX user:password?
		minTLS: "1.3"
	}

	// XXX Proxy might be wide - it does not allow to differenciate http and https proxies
	output: strings.Join([
		if input.user_agent != _|_ { "user-agent = \"\(input.user_agent)\"" },
		if input.proxy != _|_ { "proxy = \"\(input.proxy)\"" },
		if input.netRC != _|_ { "netrc-file = \"\(input.netRC)\"" },
		if input.authority != _|_ { "proxy-cacert = \"\(input.authority)\"" },
		if input.authority != _|_ { "cacert = \"\(input.authority)\"" },
		if input.proxy_user != _|_ { "proxy-user = \"\(input.proxy_user)\"" },
		if input.certificate != _|_ { "proxy-cert = \"\(input.certificate)\";" },
		if input.certificate != _|_ { "cert = \"\(input.certificate)\";" },
		if input.key != _|_ { "proxy-key = \"\(input.key)\";" },
		if input.key != _|_ { "key = \"\(input.key)\";" },
		"tlsv\(input.minTLS)",
		"proxy-tlsv1",
		"proto = \"=https\""
	]+ [""], "\n")

	// # proxy-cert
	// # proxy-key
	// # proxy-pass
}
