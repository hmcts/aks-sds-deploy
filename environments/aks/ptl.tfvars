clusters = {
  "00" = {
    kubernetes_cluster_version             = "1.33"
    kubernetes_cluster_ssh_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGk0M1s1gOt2Sy4Yhl7kvzI5Op0yNbjjghn3fVCTJ8tjF/7j98TuQtxxxr6dWb1ovKbdAmy5d9FFUUXxBGGji8ka0OKHF8Rz5/3IqzMucpTzAfNCe9xP6Y1/qnml8atYToLw3qQDWK0O/+VuK1tk8wj0uvc1xUMGoePCLIqi+7d/kBJzd3ojsi2o+JMLLAUAWbMSRCnGalojCiwSNU5zBJdBtQq2w00L77wbFukjFz5dGnk5UMCiEDNKqz4aDaiNYVq87PE1L55HlR5W1OzmTVldvIkNDuLY8Sp8sJ42nZl6BsZfBux/fM93GByokLIwZfhgFlIuVpz0VF/FVritxuUNkVg5o9z6i06vmzq0s4+HcfyTqkHuMM9uD/A9VVnbwYkQv9PV7flPW4SMOXW2EncIGGd/u1Y3CwJ8P3jNWbjy7A+yVR8N6QqWvZ2tPI5lWwUSq4J4gjbRn78MmrbDMZOWpL0hyXGX3QTJtbIteJz+bgb6H6WPL0rxv7ZbeLxmM="
    enable_automatic_channel_upgrade_patch = true

    system_node_pool = {
      min_nodes = 2
      max_nodes = 4
    }

    linux_node_pool = {
      max_nodes = 10
      max_pods  = 30
    }

    windows_node_pool = {
      max_nodes = 10
      min_nodes = 0
      os_sku    = "Windows2022"
    }

    availability_zones = ["1"]

    node_os_maintenance_window_config = {
      frequency  = "Daily"
      start_time = "16:00"
      is_prod    = false
    }

  }
}

ptl_cluster  = true
sku_tier     = "Standard"
autoShutdown = true
