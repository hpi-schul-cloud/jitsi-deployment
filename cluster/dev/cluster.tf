resource "profitbricks_k8s_cluster" "dev" {
  name        = "jitsi-dev"
  k8s_version = "1.17.2"
  maintenance_window {
    day_of_the_week = "Saturday"
    time            = "03:49:18Z"
  }
}

resource "profitbricks_k8s_node_pool" "dev_zone_1" {
  name              = "worker-3cpu-8gb"
  k8s_version       = "1.17.5"
  maintenance_window {
    day_of_the_week = "Saturday"
    time            = "16:09:33Z"
  }
  datacenter_id     = var.datacenter
  k8s_cluster_id    = profitbricks_k8s_cluster.dev.id
  cpu_family        = "INTEL_XEON"
  availability_zone = "ZONE_1"
  storage_type      = "HDD"
  node_count        = 2
  cores_count       = 3
  ram_size          = 8192
  storage_size      = 50
}

resource "profitbricks_k8s_node_pool" "dev_zone_2" {
  name              = "worker-3cpu-8gb"
  k8s_version       = "1.17.5"
  maintenance_window {
    day_of_the_week = "Wednesday"
    time            = "23:30:49Z"
  }
  datacenter_id     = var.datacenter
  k8s_cluster_id    = profitbricks_k8s_cluster.dev.id
  cpu_family        = "INTEL_XEON"
  availability_zone = "ZONE_2"
  storage_type      = "HDD"
  node_count        = 2
  cores_count       = 3
  ram_size          = 8192
  storage_size      = 50
}
