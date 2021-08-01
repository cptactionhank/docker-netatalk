package configurator

import (
	"duponey.cloud/types"
	"strings"
)

#APT: #Configurator & {
	input: {
		user_agent?: types.#UserAgent
		proxy?: types.#URL
		authority?: types.#FilePath
		certificate?: types.#FilePath
		key?: types.#FilePath
		netRC?: types.#FilePath

		check_valid?: bool //  | *true XXX this makes things fail
		sources?: types.#FilePath // string /run/secrets/APT_SOURCES
		trusted?: types.#FilePath
	}

	output: strings.Join([
		if input.user_agent != _|_ { "Acquire::http::User-Agent \"\(input.user_agent)\";" },
		if input.proxy != _|_ { "Acquire::http::Proxy \"\(input.proxy)\";" },
		if input.proxy != _|_ { "Acquire::https::Proxy \"\(input.proxy)\";" },
		if input.netRC != _|_ { "Dir::Etc::netrc \"\(input.netRC)\";" },
		if input.authority != _|_ { "Acquire::https::CAInfo \"\(input.authority)\";" },
		if input.certificate != _|_ { "Acquire::https::SSLCert \"\(input.certificate)\";" },
		if input.key != _|_ { "Acquire::https::SSLKey \"\(input.key)\";" },
		if input.check_valid != _|_ if input.check_valid == true { "Acquire::Check-Valid-Until \"yes\";" },
		if input.check_valid != _|_ if input.check_valid == false { "Acquire::Check-Valid-Until \"no\";" },
		if input.sources != _|_ { "Dir::Etc::SourceList \"\(input.sources)\";"},
		// SslForceVersion
		// FIXME in case we want away from apt-key, we would have to: cat "$SECRET_APT_SOURCES" | sed -E "s,^deb ,^deb [signed-by=/run/secrets/SECRET_GPG] ," > /tmp/sources.list
		if input.trusted != _|_ { "Dir::Etc::Trusted \"\(input.trusted)\";" },
		// NOTE because of https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=990555
		if input.authority != _|_ { "Acquire::http::CAInfo \"\(input.authority)\";" },
		if input.certificate != _|_ { "Acquire::http::SSLCert \"\(input.certificate)\";" },
		if input.key != _|_ { "Acquire::http::SSLKey \"\(input.key)\";" },

	]+ [""], "\n")
}

// Verify peer certificate and also matching between certificate name
// and server name as provided in sources.list (default values)
// Acquire::https::Verify-Peer "true";
// Acquire::https::Verify-Host "true";
// No need to downgrade, TLS will be proposed by default. Uncomment
// to have SSLv3 proposed.
// Acquire::https::SslForceVersion "SSLv3"; // TLSv1 SSLv3 <- anything more recent???
