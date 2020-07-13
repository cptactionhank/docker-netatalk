variable "IMAGE_NAME" {
  default = "untitled"
}

variable "DEBIAN_DATE" {
  default = "2020-01-01"
}

variable "DEBIAN_SUITE" {
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

# Do we have an aptproxy?
variable "APTPROXY" {
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

# Whether to fail the build if one of the runtime is outdated
variable "FAIL_WHEN_OUTDATED" {
  default = ""
}

# Just a hack to workaround buildkit path funkyness
variable "PWD" {
  default = ""
}

variable "DOCKER_CONTENT_TRUST" {
  default = "1"
}

target "shared" {
  dockerfile = "${PWD}/Dockerfile"
  context = "${PWD}"
  args = {
    APTPROXY = "${APTPROXY}"
    GOPROXY = "${GOPROXY}"
    GO111MODULE = "${GO111MODULE}"
    FAIL_WHEN_OUTDATED = "${FAIL_WHEN_OUTDATED}"

    BUILDER_BASE = "${equal(BUILDER_BASE,"") ? "${REGISTRY}/dubodubonduponey/base:builder-${DEBIAN_SUITE}-${DEBIAN_DATE}" : "${BUILDER_BASE}"}"
    RUNTIME_BASE = "${equal(RUNTIME_BASE,"") ? "${REGISTRY}/dubodubonduponey/base:runtime-${DEBIAN_SUITE}-${DEBIAN_DATE}" : "${RUNTIME_BASE}"}"

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
