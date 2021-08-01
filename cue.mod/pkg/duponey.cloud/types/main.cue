package types

#IP: =~ "^[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}$"
// #IP: 4 * [ uint8 ]
// #PrivateIP: IP
// #PrivateIP: [10, ...uint8] | [192, 168, ...] | [172, >=16 & <=32, ...]
// #IPURI: "^[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}$"
// #DomainName: "^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$"
// #Port: uint8
// #User: =~ "^[a-zA-Z0-9_.~!$&'()*+,;=:-]+$"

#Domain: =~ "^.+$"

#URL: =~ "^[^/]+://[^/]+(/.*)?$"

// XXX remove
#Hosts: [#Domain]: #IP

#FilePath: =~ ".+"

// #Certificate: string
#Certificate: =~ "^-----BEGIN CERTIFICATE-----" // .{1,}-----END CERTIFICATE-----$"

#Key: =~ "^.+$"

#Login: =~ "^.+$"

#Password: =~ ".{6,}"

#UserAgent: =~ "^.+$"
// =~ "^.+/[0-9.]+$"

#Path: =~ "^.+$"

#Identifier: =~ "^[a-zA-Z._-].*$"
