package types

import (
//	"strings"
)

#Platforms: {
	// XXX for whatever reason, this HAS TO BE DONE THIS WAY and not as below
	[...=~ "^(?:\(#AMD64)|\(#ARM64)|\(#V7)|\(#V6)|\(#PPC64LE)|\(#S390X)|\(#I386)|\(#RISCV64))$"] // | *[]
	// XXX might not work - other circumstances have demonstrated this is broken as fuck
  // [...#AMD64 | #ARM64 | #V7 | #V6 | #PPC64LE | #S390X | #I386 | #RISCV64] | *[]

  #AMD64: "linux/amd64"
  #ARM64: "linux/arm64"
  #V7: "linux/arm/v7"
  #V6: "linux/arm/v6"
  #PPC64LE: "linux/ppc64le"
  #S390X: "linux/s390x"
  #I386: "linux/386"
	#RISCV64: "linux/riscv64"

//	#fromString: string

//	if #fromString != _|_ if #fromString != "" {
//		strings.Split(#fromString, ",")
//	}
//		if #fromString == "" {
//			[]
//		}
//	}

}
