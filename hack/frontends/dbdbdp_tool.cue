package bake

import (
  "tool/os"
)

#Dubo: #Bake & {
  args: os.Getenv & {
    DEBOOTSTRAP_DATE: string | * "2020-11-10"
    DEBOOTSTRAP_SUITE: string | * "buster"

    BUILD_CREATED: string | *"1900-01-01",
    BUILD_URL: string | *"https://github.com/dubo-dubon-duponey/unknown",
    BUILD_DOCUMENTATION: string | *"\(BUILD_URL)/blob/master/README.md",
    BUILD_SOURCE: string | *"\(BUILD_URL)/tree/master",
    BUILD_VERSION: string | *"unknown",
    BUILD_REVISION: string | *"unknown",
    BUILD_VENDOR: string | *"dubodubonduponey",
    BUILD_LICENSES: string | *"MIT",
    BUILD_REF_NAME: string | *"latest",

    http_proxy: string | * ""
    https_proxy: string | * ""
    SYSTEM_TLS_CA: string | * ""
    SYSTEM_NETRC: string | * ""

    APT_OPTIONS: string | * "Acquire::HTTP::User-Agent=DuboDubonDuponey/0.1 Acquire::Check-Valid-Until=no"
    APT_GPG_KEYRING: string | * ""
    APT_TLS_CA: string | * ""
    APT_NETRC: string | * ""
    APT_SOURCES: string | * ""

    GOPROXY: string | * ""
    GO111MODULE: string | * "on"

    BASE_BASE: string | * "docker.io/dubodubonduponey/base"
    BUILDER_BASE: string | * "\(BASE_BASE):builder-\(args.DEBOOTSTRAP_SUITE)-\(args.DEBOOTSTRAP_DATE)"
    RUNTIME_BASE: string | * "\(BASE_BASE):runtime-\(args.DEBOOTSTRAP_SUITE)-\(args.DEBOOTSTRAP_DATE)"
  }
}
