target "default" {
  inherits = ["shared"]
  args = {
    BUILD_TITLE = "Netatalk"
    BUILD_DESCRIPTION = "A dubo image for Netatalk"
  }
  tags = [
    "dubodubonduponey/netatalk",
  ]
}
