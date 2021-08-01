package cake

import (
	"duponey.cloud/scullery"
)

UserDefined: scullery.#Icing & {
	subsystems: {
		// XXX why is this not working
		apt: {
			proxy: string @tag(apt_proxy, type=string)
			user_agent: "DuboDubonDuponey/1.0 (apt)"
			check_valid: false
		}
		// XXX this should be overloaded ONLY for the debootstrapping image
		curl: {
			user_agent: "DuboDubonDuponey/1.0 (curl)"
		}
	}
}
