resource "google_compute_network_peering" "usmappaoffice_eumappaoffice_peering" {
  name         = "usmappaoffice-eumappaoffice-peering"
  network      = google_compute_network.usmappaoffice_vpc_network.id
  peer_network = google_compute_network.eumappaoffice_vpc_network.id
}

resource "google_compute_network_peering" "eumappaoffice_usmappaoffice_peering" {
  name         = "eumappaoffice-usmappaoffice-peering"
  network      = google_compute_network.eumappaoffice_vpc_network.id
  peer_network = google_compute_network.usmappaoffice_vpc_network.id
}

