variable "datacenter" {
  description = "data center ID where loadtest servers should be created"
  type        = string
  default     = "df8bd51c-298f-4981-8df8-6fd07340b397" # Video Data Center
}

variable "server_count" {
  description = "number of loadtest servers"
  type        = number
  default     = 8
}

variable "hdd_size" {
  description = "size in GB of VM hard disk"
  type        = number
  default     = "20"
}

variable "image_name" {
  description = "image name"
  type        = string
  default     = "517aa2f9-8cfb-4a11-9893-db0421be1c5e" # Jitsi Torturer
}
