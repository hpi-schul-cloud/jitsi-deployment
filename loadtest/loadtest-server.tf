resource "profitbricks_server" "loadtest_server" {
  count             = var.server_count
  name              = "loadtest-server-${count.index}"
  datacenter_id     = var.datacenter
  cores             = 4
  ram               = 4096
  availability_zone = "ZONE_1"
  cpu_family        = "INTEL_XEON"
  volume {
    name         = "hdd-loadtest-${count.index}"
    size         = var.hdd_size
    disk_type    = "HDD"
    image_name   = var.image_name
  }
  nic {
    lan             = var.lan_id
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
