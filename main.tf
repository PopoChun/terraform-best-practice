provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "9.0.0"

  project_id   = var.project
  network_name = var.vpc
  subnets = [
    for s in var.subnets : {
      subnet_name   = s.name
      subnet_ip     = s.cidr
      subnet_region = var.region
    }
  ]
  ingress_rules = [
    for rule in var.ingress_rules : {
      name          = "${var.vpc}-${rule.name}"
      source_ranges = rule.source_ranges
      target_tags   = rule.target_tags
      allow         = lookup(rule, "allow", [])
      deny          = lookup(rule, "deny", [])
    }
  ]
}

resource "google_compute_disk" "vm_disk" {
  for_each   = var.attached_disks
  name       = "${var.vpc}-${each.key}-data"
  type       = each.value.type
  size       = each.value.size
  depends_on = [module.network]
}

resource "google_compute_instance" "vm" {
  for_each     = var.instances
  name         = "${var.vpc}-${each.key}"
  machine_type = each.value.machine_type
  zone         = var.zone

  tags                      = each.value.tags
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.boot_disk_size
    }
  }

  network_interface {
    subnetwork = each.value.subnet
    dynamic "access_config" {
      for_each = each.value.static_ip == true ? [1] : []
      content {
        nat_ip = google_compute_address.default[each.key].address
      }
    }
  }

  service_account {
    email  = var.default_sa
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

  metadata_startup_script = <<-EOF
  if sudo blkid /dev/sdb; then
    exit
  else
    sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard -F /dev/sdb
    sudo mkdir -p /mnt/disks/docker
    sudo mount -o discard,defaults /dev/sdb /mnt/disks/docker

    echo UUID=$(sudo blkid -s UUID -o value /dev/sdb) /mnt/disks/docker ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
  fi
  EOF

  depends_on = [
    module.network,
    google_compute_disk.vm_disk
  ]
}

resource "google_compute_attached_disk" "vm_attached_disks" {
  for_each = var.attached_disks
  disk     = google_compute_disk.vm_disk[each.key].id
  instance = google_compute_instance.vm[each.value.instance].id
  depends_on = [
    google_compute_disk.vm_disk,
    google_compute_instance.vm
  ]
}