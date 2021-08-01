package types

#Secret: {
	// XXX should be bytes as well
	{
		content: string // | bytes
	} | {
		file: #FilePath
	}
	// This evidently does not force the Dockerfile image to mount the secret there, this is merely tentative, and useful
	// for subsystems that require to point to these paths from other secrets
	path?: string
}

#Args: [#Identifier]: string // XXX unclear if this works as expected
#Secrets: [#Identifier]: #Secret // XXX... this... does... not work?
#Hosts: [#Domain]: #IP

#Tarball: {
  type: #OCI | #DOCKER | #TAR
  location: #Path

  #DOCKER: "docker"
  #TAR: "tar"
  #OCI: "oci"
}

#ResolveMode: {
	// XXX unlikely to work because of cue
	// #DEFAULT | #PULL | #LOCAL | *#DEFAULT
	=~ "^(?:\(#DEFAULT)|\(#PULL)|\(#LOCAL))$"
	#DEFAULT: "default"
	#PULL: "pull"
	#LOCAL: "local"
}

#NetworkMode: {
	// XXX unlikely to work because of cue
	// #NONE | #HOST | * #SANDBOX
	=~ "^(?:\(#NONE)|\(#HOST)|\(#SANDBOX))$"
	#NONE: "none"
	#HOST: "host"
	#SANDBOX: "sandbox"
}

#Progress: {
	// XXX unlikely to work because of cue
	// #PLAIN | #TTY | *#AUTO
	=~ "^(?:\(#PLAIN)|\(#TTY)|\(#AUTO))$"
  #AUTO: "auto"
  #PLAIN: "plain"
  #TTY: "tty"
}

