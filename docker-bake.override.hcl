variable "REGISTRY" {
  default = "docker.io"
}

target "default" {
  inherits = ["shared"]
  args = {
    BUILD_TITLE = "Netatalk"
    BUILD_DESCRIPTION = "A dubo image for Netatalk"
  }
  tags = [
    "${REGISTRY}/dubodubonduponey/netatalk",
  ]
}
