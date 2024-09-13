# output "instance_name" {
#   value = google_compute_instance.test-instance.name 
# }

# output "instance_network" {
#   value = google_compute_instance.test-instance.network_interface.0.network
# }

# output "instance_subnet" {
#   value = google_compute_instance.test-instance.network_interface.0.subnetwork
# }

# output "instance_zone" {
#   value = google_compute_instance.test-instance.zone
# }

# output "instance_ip" {
#   value = google_compute_instance.test-instance.network_interface.0.network_ip
# }

# output "instance_ids_count" {
#   description = "IDs of gce instances"
#   value = google_compute_instance.app.*.id
# }

# output "instance_ids_for_each" {
#   description = "IDs of gce instances"
#   value = {for i in keys(var.instances): i => google_compute_instance.foobar[i].instance_id}
# }