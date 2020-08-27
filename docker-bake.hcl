variable "IMAGE_NAME" {
  default = "untitled"
}

variable "DEBOOTSTRAP_DATE" {
  default = "2020-01-01"
}

variable "DEBOOTSTRAP_SUITE" {
  default = "buster"
}

variable "BUILDER_BASE" {
  default = ""
}

variable "RUNTIME_BASE" {
  default = ""
}

#########################
# Image main properties
#########################
variable "REGISTRY" {
  default = "docker.io"
}

variable "VENDOR" {
  default = "dubodubonduponey"
}

variable "IMAGE_TAG" {
  default = "latest"
}

#########################
# Metadata
#########################
variable "TITLE" {
  default = "No title"
}

variable "DESCRIPTION" {
  default = "No description"
}

variable "DATE" {
  default = "unknown"
}

variable "URL" {
  default = "unknown"
}

variable "DOCUMENTATION" {
  default = "unknown"
}

variable "SOURCE" {
  default = "unknown"
}

variable "VERSION" {
  default = "unknown"
}

variable "REVISION" {
  default = "unknown"
}

variable "LICENSE" {
  default = "unknown"
}

#########################
# Behavioral
#########################

# Apt related settings
variable "APT_OPTIONS" {
  default = "Acquire::HTTP::User-Agent=DuboDubonDuponey/0.1 Acquire::Check-Valid-Until=no"
}

variable "APT_SOURCES" {
  default = ""
}

variable "APT_TRUSTED" {
  default = ""
}

# Do we have a goproxy?
variable "GOPROXY" {
  default = ""
}

# Go modules are on by default
variable "GO111MODULE" {
  default = "on"
}

# Do we have http and https proxies for other operations?
variable "http_proxy" {
  default = ""
}

variable "https_proxy" {
  default = ""
}

# Just a hack to workaround buildkit path funkyness
variable "PWD" {
  default = "."
}

# Toggle on content trust by default
variable "DOCKER_CONTENT_TRUST" {
  default = "1"
}

target "shared" {
  dockerfile = "${PWD}/Dockerfile"
  context = "${PWD}/context"
  args = {
    APT_OPTIONS = "${APT_OPTIONS}"
    APT_SOURCES = "${APT_SOURCES}"
    APT_TRUSTED = "${APT_TRUSTED}"

    http_proxy = "${http_proxy}"
    https_proxy = "${https_proxy}"

    GOPROXY = "${GOPROXY}"
    GO111MODULE = "${GO111MODULE}"

    BUILDER_BASE = "${equal(BUILDER_BASE,"") ? "${REGISTRY}/dubodubonduponey/base:builder-${DEBOOTSTRAP_SUITE}-${DEBOOTSTRAP_DATE}" : "${BUILDER_BASE}"}"
    RUNTIME_BASE = "${equal(RUNTIME_BASE,"") ? "${REGISTRY}/dubodubonduponey/base:runtime-${DEBOOTSTRAP_SUITE}-${DEBOOTSTRAP_DATE}" : "${RUNTIME_BASE}"}"

    BUILD_TITLE = "${TITLE}"
    BUILD_DESCRIPTION = "${DESCRIPTION}"
    BUILD_CREATED = "${DATE}"
    BUILD_URL = "${URL}"
    BUILD_DOCUMENTATION = "${URL}/blob/master/README.md"
    BUILD_SOURCE = "${URL}/tree/master"
    BUILD_VERSION = "${VERSION}"
    BUILD_REVISION = "${REVISION}"
    BUILD_VENDOR = "${VENDOR}"
    BUILD_LICENSES = "${LICENSE}"
    BUILD_REF_NAME = "${IMAGE_TAG}"
  }
  tags = [
    "${REGISTRY}/${VENDOR}/${IMAGE_NAME}:${IMAGE_TAG}",
  ]
  pull = true
  no-cache = false
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
    "linux/arm/v6",
  ]
  cache-to = [
    "type=local,dest=${PWD}/cache/buildkit"
  ]
  cache-from = [
    "type=local,src=${PWD}/cache/buildkit"
  ]
}

# tags,args,context,dockerfile,output, platform, labels, no-cache, labels, no-cache, pull,
# cache-from, cache-to, inherits, target

# -> secrets, ssh <-

#buildctl build ... \
#--output type=image,name=localhost:5000/myrepo:image,push=true \
#--export-cache type=registry,ref=localhost:5000/myrepo:buildcache \
#--import-cache type=registry,ref=localhost:5000/myrepo:buildcache \
# linux/amd64,linux/arm64,linux/arm/v7
