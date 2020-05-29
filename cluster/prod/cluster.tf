resource "profitbricks_k8s_cluster" "prod" {
  name        = "jitsi-prod"
  k8s_version = "1.17.2"
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "22:30:20Z"
  }
}

resource "profitbricks_k8s_node_pool" "prod_zone_1" {
  name              = "worker-10cpu-8gb"
  k8s_version       = "1.17.5"
  maintenance_window {
    day_of_the_week = "Saturday"
    time            = "10:26:26Z"
  }
  datacenter_id     = var.datacenter
  k8s_cluster_id    = profitbricks_k8s_cluster.prod.id
  cpu_family        = "INTEL_XEON"
  availability_zone = "ZONE_1"
  storage_type      = "HDD"
  node_count        = 3
  cores_count       = 10
  ram_size          = 8192
  storage_size      = 50
}

resource "profitbricks_k8s_node_pool" "prod_zone_2" {
  name              = "worker-10cpu-8gb"
  k8s_version       = "1.17.5"
  maintenance_window {
    day_of_the_week = "Wednesday"
    time            = "22:52:42Z"
  }
  datacenter_id     = var.datacenter
  k8s_cluster_id    = profitbricks_k8s_cluster.prod.id
  cpu_family        = "INTEL_XEON"
  availability_zone = "ZONE_2"
  storage_type      = "HDD"
  node_count        = 3
  cores_count       = 10
  ram_size          = 8192
  storage_size      = 50
}
