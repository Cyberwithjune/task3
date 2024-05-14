# VPN for EU Office
resource "google_compute_vpn_gateway" "eumappaoffice_vpn_gateway" {
  name          = "eumappaoffice-vpn-gateway"
  network       = google_compute_network.eumappaoffice_vpc_network.id
  region        = "europe-west2"
}

# VPN for ASIA Office
resource "google_compute_vpn_gateway" "asmappaoffice_vpn_gateway" {
  name          = "asmappaoffice-vpn-gateway"
  network       = google_compute_network.asmappaoffice_vpc_network.id
  region        = "asia-northeast1"
}

# External Static IP for EU Office
resource "google_compute_address" "eumappaoffice_vpn_ip" {
  name          = "eumappaoffice-vpn-ip"
  region        = "europe-west2"
}

resource "google_compute_address" "asmappaoffice_vpn_ip" {
  name          = "asmappaoffice-vpn-ip"
  region        = "asia-northeast1"
  
}

#VPN Tunnel for Asia Office to EU HQ
data "google_secret_manager_secret_version" "vpn_secret" {
  secret    = "vpn-shared-secret"
  version   = "1"
}

resource "google_compute_vpn_tunnel" "asmappaoffice_eumappaoffice_tunnel" {
  name               = "asmappaoffice-eumappaoffice-tunnel"
  region             = "asia-northeast1"
  target_vpn_gateway = google_compute_vpn_gateway.asmappaoffice_vpn_gateway.id
  peer_ip            = google_compute_address.eumappaoffice_vpn_ip.address
  shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
  ike_version        = 2
  
  local_traffic_selector   = ["192.168.72.0/24"]
  remote_traffic_selector  = ["10.135.2.0/24"]
  
  depends_on = [ 
    google_compute_forwarding_rule.asmappaoffice_esp,
    google_compute_forwarding_rule.asmappaoffice_udp500,
    google_compute_forwarding_rule.asmappaoffice_udp4500]
}

# Route for Asia Office to EU HQ
resource "google_compute_route" "asmappaoffice_eumappaoffice_route" {
  name                  = "asmappaoffice-eumappaoffice-route"
  network               = google_compute_network.asmappaoffice_vpc_network.id
  dest_range            = "10.135.2.0/24"
  next_hop_vpn_tunnel   = google_compute_vpn_tunnel.asmappaoffice_eumappaoffice_tunnel.id
  priority              = 1000
}

resource "google_compute_forwarding_rule" "asmappaoffice_esp" {
  name                  = "asmappaoffice-esp"
  region                = "asia-northeast1"
  ip_protocol           = "ESP"
  ip_address            = google_compute_address.asmappaoffice_vpn_ip.address
  target                = google_compute_vpn_gateway.asmappaoffice_vpn_gateway.id
  depends_on            = [google_compute_vpn_gateway.asmappaoffice_vpn_gateway]
  
}


resource "google_compute_forwarding_rule" "asmappaoffice_udp500" {
  name                  = "asmappaoffice-udp500"
  region                = "asia-northeast1"
  ip_protocol           = "UDP"
  ip_address            = google_compute_address.asmappaoffice_vpn_ip.address
  port_range            = "500"
  target                = google_compute_vpn_gateway.asmappaoffice_vpn_gateway.id
  
}

resource "google_compute_forwarding_rule" "asmappaoffice_udp4500" {
  name                  = "asmappaoffice-udp4500"
  region                = "asia-northeast1"
  ip_protocol           = "UDP"
  ip_address            = google_compute_address.asmappaoffice_vpn_ip.address
  port_range            = "4500"
  target                = google_compute_vpn_gateway.asmappaoffice_vpn_gateway.id
}

# Reverse VPN Tunnel for EU HQ to Asia Office
resource "google_compute_vpn_tunnel" "eumappaoffice_asmappaoffice_tunnel" {
  name               = "eumappaoffice-asmappaoffice-tunnel"
  region             = "europe-west2"
  target_vpn_gateway = google_compute_vpn_gateway.eumappaoffice_vpn_gateway.id
  peer_ip            = google_compute_address.asmappaoffice_vpn_ip.address
  shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
  ike_version        = 2
  
  local_traffic_selector    = ["10.135.2.0/24"]
  remote_traffic_selector   = ["192.168.72.0/24"] 
   
    depends_on = [ 
        google_compute_forwarding_rule.eumappaoffice_esp,
        google_compute_forwarding_rule.eumappaoffice_udp500,
        google_compute_forwarding_rule.eumappaoffice_udp4500]

}

# Route for EU HQ to Asia Office
resource "google_compute_route" "eumappaoffice_asmappaoffice_route" {
  depends_on            = [google_compute_vpn_tunnel.eumappaoffice_asmappaoffice_tunnel] 
  name                  = "eumappaoffice-asmappaoffice-route"
  network               = google_compute_network.eumappaoffice_vpc_network.id
  dest_range            = "192.168.72.0/24"
  next_hop_vpn_tunnel   = google_compute_vpn_tunnel.eumappaoffice_asmappaoffice_tunnel.id
}

# Forwarding Rules for EU VPN
resource "google_compute_forwarding_rule" "eumappaoffice_esp" {
  name                  = "eumappaoffice-esp"
  region                = "europe-west2"
  ip_protocol           = "ESP"
  ip_address            = google_compute_address.eumappaoffice_vpn_ip.address
  target                = google_compute_vpn_gateway.eumappaoffice_vpn_gateway.id
}

resource "google_compute_forwarding_rule" "eumappaoffice_udp500" {
  name                  = "eumappaoffice-udp500"
  region                = "europe-west2"
  ip_protocol           = "UDP"
  ip_address            = google_compute_address.eumappaoffice_vpn_ip.address
  port_range            = "500"
  target                = google_compute_vpn_gateway.eumappaoffice_vpn_gateway.id
}

resource "google_compute_forwarding_rule" "eumappaoffice_udp4500" {
  name                  = "eumappaoffice-udp4500"
  region                = "europe-west2"
  ip_protocol           = "UDP"
  ip_address            = google_compute_address.eumappaoffice_vpn_ip.address
  port_range            = "4500"
  target                = google_compute_vpn_gateway.eumappaoffice_vpn_gateway.id
}