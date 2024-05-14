resource "google_compute_network" "eumappaoffice_vpc_network" {
  project       = "red-studio-419223"
  name          = "eumappaoffice"
  auto_create_subnetworks = false
  
}

# Subnet
resource "google_compute_subnetwork" "eumappaofffice_vpc_subnet" {
  name          = "eum1-subnet"
  network       = google_compute_network.eumappaoffice_vpc_network.id
  ip_cidr_range = "10.135.2.0/24"
  region        = "europe-west2"
  private_ip_google_access = true
}

# Firewall
resource "google_compute_firewall" "eumappaoffice_firewall" {
  name        = "eumappaoffice-firewall"
  network     = google_compute_network.eumappaoffice_vpc_network.id
  

  allow {
    protocol  = "tcp"
    ports     = ["80"]
  }

  source_ranges = ["10.135.2.0/24", "172.16.32.0/24","172.16.56.0/24", "192.168.72.0/24"]
  target_tags = ["eumappaoffice-http-server", "usmappaoffice-http-server", "asmappaoffice-rdp-server"]
}

# # VM
resource "google_compute_instance" "eumappaoffice_vm" {
  depends_on = [google_compute_subnetwork.eumappaofffice_vpc_subnet]
  name         = "eumappaoffice-vm"
  machine_type = "e2-medium"
  zone         = "europe-west2-a"
  
  
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20240415"
    }
  }
  network_interface {
    network = google_compute_network.eumappaoffice_vpc_network.id
    subnetwork = google_compute_subnetwork.eumappaofffice_vpc_subnet.id
    
    access_config {
    }
  }

  metadata = {
    startup-script = file("${path.module}/homepage-script.sh")
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["eumappaoffice-http-server"]
}