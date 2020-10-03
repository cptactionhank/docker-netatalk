package bake

import (
	"tool/exec"
	"strings"
	"tool/os"
)

foo: *"default foo value" | string @tag(foo)

AMD64: "linux/amd64"
ARM64: "linux/arm64"
V7: "linux/arm/v7"
V6: "linux/arm/v6"
PPC64LE: "linux/ppc64le"
S390X: "linux/s390x"
I386: "linux/386"

#Platform: AMD64 | ARM64 | V7 | V6 | PPC64LE | S390X | I386 | "local"

_default_platformset=AMD64 + "," + ARM64 + "," + V7 + "," + PPC64LE + "," + S390X
// + "," + I386
// + V6 + ","
_tag_platforms: string | * _default_platformset | string @tag(platforms,type=string)
_tag_no_cache: bool | * false | bool @tag(no_cache,type=bool)
_tag_pull: bool | * true | bool @tag(pull,type=bool)
_tag_tags: string | * "" | string @tag(tags,type=string)
_tag_cache_type: string | * "local" | string @tag(cache_type,type=string)
_tag_cache_location: string | * "./cache/buildkit" | string @tag(cache_location,type=string)
_tag_progress: "auto" | "plain" | "tty" | *"auto" | string @tag(progress,type=string)

env: os.Getenv & {}

#Bake: {
	dockerfile: string | * "Dockerfile"
	dockerfiledir: string | * "."
	context: string | * "./context"
	target: string | * ""
	// platforms: _platforms
	args: [string]: string
	pull: _tag_pull
	no_cache: _tag_no_cache
	// XXX did I just break platform passthrough behavior?
  platforms: [...#Platform] | * strings.Split(_tag_platforms, ",")
	tags: [...string]
	tags: strings.Split(_tag_tags, ",")
	_tags: strings.Join(tags, ",")
	cache_to: [
    if _tag_cache_type == "local" {
      "type=\(_tag_cache_type),dest=\(_tag_cache_location),mode=max"
    }
	] + [
    if _tag_cache_type == "registry" {
      "type=\(_tag_cache_type),ref=\(_tag_cache_location),mode=max"
    }
	]
	cache_from: [
    if _tag_cache_type == "local" {
      "type=\(_tag_cache_type),src=\(_tag_cache_location)"
    }
  ] + [
    if _tag_cache_type == "registry" {
      "type=\(_tag_cache_type),ref=\(_tag_cache_location)"
    }
  ]

	directory: string | * ""
	tarball: string | * ""
	tarballtype: "docker" | "tar" | "oci" | * "tar"

	progress: _tag_progress

  // reargs: [ for key, item in args {"--opt=build-arg:\(key)=\(item)"} ]
  // ["--opt=build-arg:\(key)=\(item)" for key, item in args]

  debug: exec.Run & {
    cmd: [
      "echo",
      "buildctl", "build",
    ] + [
      for key, item in args {
        "--opt=build-arg:\(key)=\(item)"
      }
    ] +
      strings.Split("--export-cache=" + strings.Join(cache_to, " --export-cache="), " ") +
      strings.Split("--import-cache=" + strings.Join(cache_from, " --import-cache="), " ") +
    [
      if _tags != "" {
        "--output=type=image," + "\"" + "name=\(_tags)" + "\"" + ",push=true,oci-mediatypes=true"
      }
    ] + [
      if directory != "" {
        "--output=type=local,dest=\(directory)"
      }
    ] + [
      if tarball != "" {
        "--output=type=\(tarballtype),dest=\(tarball)"
      }
    ] + [
      if no_cache == true {
        "--no-cache"
      }
    ] + [
      "--frontend", "dockerfile.v0",
      "--local", "context=\(context)",
      "--local", "dockerfile=\(dockerfiledir)",
      "--opt", "target=\(target)",
      "--opt", "filename=\(dockerfile)",
      "--opt", "platform=\(strings.Join(platforms, ","))",
    ]
    $after: [env]
    // stdout: string // capture stdout
  }

	run: exec.Run & {
    cmd: [
      "buildctl", "build",
    ] + [
      for key, item in args {
        "--opt=build-arg:\(key)=\(item)"
      }
    ] +
      strings.Split("--export-cache=" + strings.Join(cache_to, " --export-cache="), " ") +
      strings.Split("--import-cache=" + strings.Join(cache_from, " --import-cache="), " ") +
    [
      if _tags != "" {
        "--output=type=image," + "\"" + "name=\(_tags)" + "\"" + ",push=true,oci-mediatypes=true"
      }
    ] + [
      if directory != "" {
        "--output=type=local,dest=\(directory)"
      }
    ] + [
      if tarball != "" {
        "--output=type=\(tarballtype),dest=\(tarball)"
      }
    ] + [
      if no_cache == true {
        "--no-cache"
      }
    ] + [
      "--frontend", "dockerfile.v0",
      "--local", "context=\(context)",
      "--local", "dockerfile=\(dockerfiledir)",
      "--opt", "target=\(target)",
      "--opt", "filename=\(dockerfile)",
      "--opt", "platform=\(strings.Join(platforms, ","))",
      "--progress", "\(progress)"
    ]
    $after: [env]
  }
}
    // XXX what does buildkit do in that case? is it a dockerfile.v0 opt?
    //] + [
    //  if pull == true { "--pull" }
