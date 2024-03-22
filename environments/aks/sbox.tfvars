clusters = {
  "00" = {
    kubernetes_version = "1.28"
  },
  "01" = {
    kubernetes_version = "1.28"
  }
}

enable_automatic_channel_upgrade_patch = true

kubernetes_cluster_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqPFmlkJn9vCOklB9wOJEAr+h36naEvWCH2LP6wVMTnbWkgwwhRvtVGeFeDo5jhlTJGk8/RyCnuQpoKfvfYNqr/5fhr0xa7CNJhb2NdUmv8u811APXKaf8psElQz4LzFb6HBcKapkVB1DQwUCVREY+BCnXtBZ1v6V24TO9YbJASs/BaPgZQJLThVGNe24jV0zRWDAy1RElPT8P1wO4k5hoDXg4NRoQt5IxqcpTUncVGN705ggqLf96zS70fPVlhLL5L6yBv4/0y9t4uo7NR5mKwDIRlpyXONpFpMGzj0zWLm/HDQqZNrD4Ycs2UolJcBk+YlUXTV6VyrnpmyKoVGvlOW8IpJLASW8HalNeOWTw5WsbjpY8rCrgasO6lMC3tI7t8yqFHFJ+EAqYZtVJoLO+ag97QZADlm2vcvctSGCAr8hqwYfb2UqqlDTuX/H8USqelCNa5NJAH7IMF1p1M9n0ohvT91U3KdtUvgu/8psuIXD1iEDNKQ3gwManbeRQ79M="

system_node_pool = {
  vm_size   = "Standard_D4ds_v5",
  min_nodes = 2,
  max_nodes = 4
}

linux_node_pool = {
  vm_size   = "Standard_D4ds_v5",
  min_nodes = 2,
  max_nodes = 4,
  max_pods  = 40
}

arm_node_pool = {
  vm_size   = "Standard_D4pds_v5",
  min_nodes = 2,
  max_nodes = 4,
  max_pods  = 40
}

windows_node_pool = {
  vm_size   = "Standard_D4ds_v5",
  min_nodes = 2,
  max_nodes = 4
}

availability_zones = ["1"]

autoShutdown = true

node_os_maintenance_window_config = {
  frequency   = "Daily"
  duration    = 4
  start_time  = "16:00"
}