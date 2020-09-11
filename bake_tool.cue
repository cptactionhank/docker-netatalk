package bake

command: {
  image: #Dubo & {
    args: {
      BUILD_TITLE: "Netatalk"
      BUILD_DESCRIPTION: "A dubo image for Netatalk based on \(args.DEBOOTSTRAP_SUITE) (\(args.DEBOOTSTRAP_DATE))"
    }
  }
}
