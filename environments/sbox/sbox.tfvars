enable_debug = "true"

network_address_space                  = "10.140.0.0/18"
aks_00_subnet_cidr_blocks              = "10.140.0.0/20"
aks_01_subnet_cidr_blocks              = "10.140.16.0/20"
iaas_subnet_cidr_blocks                = "10.140.32.0/25"
application_gateway_subnet_cidr_blocks = "10.140.32.128/25"
postgresql_subnet_cidr_blocks          = "10.140.40.0/25"

additional_subnets = [
  {
    name           = "vh_private_endpoints"
    address_prefix = "10.140.33.0/25"
  },
  {
    name           = "api-management"
    address_prefix = "10.140.33.128/25"
  },
  {
    name           = "redis",
    address_prefix = "10.140.34.0/25"
  },
  {
    name           = "private-endpoints"
    address_prefix = "10.140.36.0/22"
  },
]

private_dns_subscription = "1497c3d7-ab6d-4bb7-8a10-b51d03189ee3"
private_dns_zones = [
  "sandbox.platform.hmcts.net",
  "sbox.platform.hmcts.net",
]

hub = "sbox"

additional_routes = [
  {
    name                   = "10_0_0_0"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "172_16_0_0"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  },
  {
    name                   = "192_168_0_0"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.200.36"
  }
]

clusters = {
  "00" = {
    kubernetes_version = "1.22"
  },
  "01" = {
    kubernetes_version = "1.22"
  }
}

kubernetes_cluster_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqPFmlkJn9vCOklB9wOJEAr+h36naEvWCH2LP6wVMTnbWkgwwhRvtVGeFeDo5jhlTJGk8/RyCnuQpoKfvfYNqr/5fhr0xa7CNJhb2NdUmv8u811APXKaf8psElQz4LzFb6HBcKapkVB1DQwUCVREY+BCnXtBZ1v6V24TO9YbJASs/BaPgZQJLThVGNe24jV0zRWDAy1RElPT8P1wO4k5hoDXg4NRoQt5IxqcpTUncVGN705ggqLf96zS70fPVlhLL5L6yBv4/0y9t4uo7NR5mKwDIRlpyXONpFpMGzj0zWLm/HDQqZNrD4Ycs2UolJcBk+YlUXTV6VyrnpmyKoVGvlOW8IpJLASW8HalNeOWTw5WsbjpY8rCrgasO6lMC3tI7t8yqFHFJ+EAqYZtVJoLO+ag97QZADlm2vcvctSGCAr8hqwYfb2UqqlDTuX/H8USqelCNa5NJAH7IMF1p1M9n0ohvT91U3KdtUvgu/8psuIXD1iEDNKQ3gwManbeRQ79M="

system_node_pool = {
  min_nodes = 2,
  max_nodes = 4
}

linux_node_pool = {
  min_nodes = 2,
  max_nodes = 4
}

windows_node_pool = {
  min_nodes = 2,
  max_nodes = 4
}

availability_zones = ["1"]
