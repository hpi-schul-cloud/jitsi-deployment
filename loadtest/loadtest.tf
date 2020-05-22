resource "profitbricks_lan" "loadtest_lan" {
  name          = "loadtest"
  datacenter_id = var.datacenter
  public        = true
}

resource "profitbricks_server" "loadtest_server" {
  count             = var.server_count
  name              = "loadtest-server-${count.index}"
  datacenter_id     = var.datacenter
  cores             = 16
  ram               = 16384
  availability_zone = "ZONE_1"
  cpu_family        = "INTEL_XEON"
  image_name        = var.image_name

  volume {
    name      = "hdd-loadtest-${count.index}"
    size      = var.hdd_size
    disk_type = "HDD"
  }

  nic {
    lan             = profitbricks_lan.loadtest_lan.id
    dhcp            = true
    firewall_active = true

    firewall {
      protocol         = "TCP"
      name             = "SSH"
      port_range_start = 22
      port_range_end   = 22
    }
  }
}
