resource "digitalocean_droplet" "myc2-1" {
    image = "ubuntu-20-04-x64"
    name = "myc2-1"
    region = "sfo2"
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = [
      data.digitalocean_ssh_key.keyname.id
    ]

connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install docker, curl, and the C2 Cradle
      "sudo apt-get update",
      "sudo apt-get -y install curl",
      "sudo apt install -y docker.io",
      "sudo systemctl enable docker --now",
      "sudo wget 'https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)' -O /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo apt-get install git",
      "git clone https://github.com/cedowens/C2_Cradle",
    ]
  }
}

resource "digitalocean_firewall" "myc2-1" {
        name = "myc2rule"
        droplet_ids = ["${digitalocean_droplet.myc2-1.id}"]

	inbound_rule {
		protocol	= "tcp"
		port_range 	= "22"
		source_addresses = ["127.0.0.1"]
	}
	
	inbound_rule {
		protocol	= "tcp"
		port_range	= "80"
		source_addresses = ["10.0.0.0"]
	}
	
	inbound_rule {
		protocol	= "tcp"
		port_range 	= "443"
		source_addresses = ["10.0.0.0"]
	}

	inbound_rule {
                protocol        = "tcp"
                port_range      = "7443"
                source_addresses = ["127.0.0.1"]
        }

	inbound_rule {
                protocol        = "tcp"
                port_range      = "8443"
                source_addresses = ["127.0.0.1"]
        }

	outbound_rule {
		protocol	= "tcp"
		port_range	= "all"
		destination_addresses = ["0.0.0.0/0", "::/0"]
	}

}
