resource "google_compute_network" "asmappaoffice_vpc_network" {
  project      = "red-studio-419223"
  name         = "asmappaoffice"
  auto_create_subnetworks = false
  
}

# Subnet
resource "google_compute_subnetwork" "asmappaoffice_vpc_subnet" {
  name          = "as1-subnet"
  network       = google_compute_network.asmappaoffice_vpc_network.id
  ip_cidr_range = "192.168.72.0/24"
  region        = "asia-northeast1"
  private_ip_google_access = true
}

# Firewall
resource "google_compute_firewall" "asmappaoffice_allow_rdp" {
  name        = "asmappaoffice-allow-rdp"
  network     = google_compute_network.asmappaoffice_vpc_network.id
  

  allow {
    protocol  = "tcp"
    ports     = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["asmappaoffice-rdp-server"]
}

# VM
resource "google_compute_instance" "asmappaoffice_vm" {
  depends_on = [google_compute_subnetwork.asmappaoffice_vpc_subnet]
  name         = "asmappaoffice-vm"
  machine_type = "n2-standard-4"
  zone         = "asia-northeast1-a"
  
  
  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    }
  }
  network_interface {
    network = google_compute_network.asmappaoffice_vpc_network.id
    subnetwork = google_compute_subnetwork.asmappaoffice_vpc_subnet.id
    
    access_config {
    }
  }

  
  tags = ["asmappaoffice-rdp-server"]

}