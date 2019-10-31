provider "google" {
  credentials = "${file("./credentials.json")}"
  project     = var.gcp_project
  region      = var.gcp_region
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}

locals {
  rancher_command = "sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.3.2 --server ${var.address} --token ${var.token} --ca-checksum ${var.checksum}"
}

resource "random_id" "worker_instance_id" {
  count       = var.nodes
  byte_length = 8
}

resource "google_compute_firewall" "please_hack_me" {
  name    = "rancher-node-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  direction = "INGRESS"
}

resource "google_compute_instance" "worker" {
  count        = var.nodes
  name         = "rancher-gcp-node-worker-${random_id.worker_instance_id[count.index].hex}"
  machine_type = "n1-standard-1"
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "demo:${file("~/keys/aws_terraform.pub")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "demo"
      private_key = "${file("~/keys/aws_terraform")}"
      host        = self.network_interface.0.access_config.0.nat_ip
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`",
      "${local.rancher_command} --worker --address ${self.network_interface.0.access_config.0.nat_ip}"
    ]
  }
}