enable_debug = "true"

network_address_space                  = "10.141.0.0/18"
aks_00_subnet_cidr_blocks              = "10.141.0.0/20"
aks_01_subnet_cidr_blocks              = "10.141.16.0/20"
iaas_subnet_cidr_blocks                = "10.141.32.0/25"
application_gateway_subnet_cidr_blocks = "10.141.32.128/25"
postgresql_subnet_cidr_blocks          = "10.141.40.0/25"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.141.33.0/25"
  },
  {
    name           = "api-management"
    address_prefix = "10.141.33.128/25"
  },
  {
    name           = "redis",
    address_prefix = "10.141.34.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.141.36.0/22"
  }
]

private_dns_subscription = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
private_dns_zones = [
  "test.platform.hmcts.net",
  "platform.hmcts.net",
  "mailrelay.platform.hmcts.net",
]

hub = "nonprod"


clusters = {
  "00" = {
    kubernetes_version = "1.22.6"
  },
  "01" = {
    kubernetes_version = "1.22.6"
  }
}
kubernetes_cluster_agent_min_count = "1"
kubernetes_cluster_agent_max_count = "4"
kubernetes_cluster_ssh_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqPFmlkJn9vCOklB9wOJEAr+h36naEvWCH2LP6wVMTnbWkgwwhRvtVGeFeDo5jhlTJGk8/RyCnuQpoKfvfYNqr/5fhr0xa7CNJhb2NdUmv8u811APXKaf8psElQz4LzFb6HBcKapkVB1DQwUCVREY+BCnXtBZ1v6V24TO9YbJASs/BaPgZQJLThVGNe24jV0zRWDAy1RElPT8P1wO4k5hoDXg4NRoQt5IxqcpTUncVGN705ggqLf96zS70fPVlhLL5L6yBv4/0y9t4uo7NR5mKwDIRlpyXONpFpMGzj0zWLm/HDQqZNrD4Ycs2UolJcBk+YlUXTV6VyrnpmyKoVGvlOW8IpJLASW8HalNeOWTw5WsbjpY8rCrgasO6lMC3tI7t8yqFHFJ+EAqYZtVJoLO+ag97QZADlm2vcvctSGCAr8hqwYfb2UqqlDTuX/H8USqelCNa5NJAH7IMF1p1M9n0ohvT91U3KdtUvgu/8psuIXD1iEDNKQ3gwManbeRQ79M="
availability_zones                 = ["1"]

