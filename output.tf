# Outputs
output "eumappaoffice_vpn_ip_address" {
  value = google_compute_address.eumappaoffice_vpn_ip.address
}

output "asmappaoffice_vpn_ip_address" {
  value = google_compute_address.asmappaoffice_vpn_ip.address
}

output "eumappaoffice_vm_internal_ip" {
    description = "Internal IP of the eumappaoffice VM"
    value       = google_compute_instance.eumappaoffice_vm.network_interface[0].network_ip
}