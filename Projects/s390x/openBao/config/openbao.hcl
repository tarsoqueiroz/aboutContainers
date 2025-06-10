ui                = true

disable_mlock     = "true"

api_addr          = "https://openbao.0a0f6017.nip.io:8200"

default_lease_ttl = "168h"
max_lease_ttl     = "720h"

storage "file" {
  path            = "/openbao/data"
}

listener "tcp" {
  address         = "[::]:8200"
  tls_disable     = "false"
  tls_cert_file   = "/openbao/certs/openbao-cert.pem"
  tls_key_file    = "/openbao/certs/openbao-key.pem"
}
