resource "google_compute_network" "usmappaoffice_vpc_network" {
  project       = "red-studio-419223"
  name          = "usmappaoffice"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "usmappaoffice_vpc_subnet" {
  name          = "usm1-subnet"
  network       = google_compute_network.usmappaoffice_vpc_network.id
  ip_cidr_range = "172.16.32.0/24"
  region        = "us-west1"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "usmappaoffice_vpc_subnet2" {
  name          = "usm2-subnet"
  network       = google_compute_network.usmappaoffice_vpc_network.id
  ip_cidr_range = "172.16.56.0/24"
  region        = "us-west4" 
  private_ip_google_access = true
}

# Firewall
resource "google_compute_firewall" "ustoeumappaoffice_firewall" {
  name        = "ustoeumappaoffice-firewall"
  network     = google_compute_network.usmappaoffice_vpc_network.id
  

  allow {
    protocol  = "tcp"
    ports     = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]
  target_tags = ["usmappaoffice-http-server", "iap-ssh-allowed"]
}

# VM
resource "google_compute_instance" "usmappaoffice_vm" {
  depends_on = [google_compute_subnetwork.usmappaoffice_vpc_subnet]
  name         = "usmappaoffice-vm"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  
  
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20240415"
    }
  }
  network_interface {
    network = google_compute_network.usmappaoffice_vpc_network.id
    subnetwork = google_compute_subnetwork.usmappaoffice_vpc_subnet.id
    
    access_config {
    }
  }


  tags = ["usmappaoffice-firewall-server", "iap-ssh-allowed"]
}

resource "google_compute_instance" "usmappaoffice_vm2" {
  depends_on = [google_compute_subnetwork.usmappaoffice_vpc_subnet2]
  name         = "usmappaoffice-vm2"
  machine_type = "e2-medium"
  zone         = "us-west4-c"
  
  
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20240415"
    }
  }
  network_interface {
    network = google_compute_network.usmappaoffice_vpc_network.id
    subnetwork = google_compute_subnetwork.usmappaoffice_vpc_subnet2.id
    
    access_config {
    }

  }

  tags = ["usmappaoffice-firewall-server", "iap-ssh-allowed"]
}