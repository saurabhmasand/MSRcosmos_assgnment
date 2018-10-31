# Create a new SSH key
resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = "${file("/Users/saurabhsingh/.ssh/id_rsa.pub")}"
}

# Create a new Droplet using the SSH key
#resource "digitalocean_droplet" "web1" {
#  image    = "ubuntu-18-04-x64"
#  name     = "MSR-test-Instance-1"
#  region   = "blr1"
#  size     = "s-1vcpu-1gb"
#  ssh_keys = ["${digitalocean_ssh_key.default.id}"]
#}

# Create a another Droplet using the SSH key
#resource "digitalocean_droplet" "web2" {
#  image    = "ubuntu-18-04-x64"
#  name     = "MSR-test-Instance-2"
#  region   = "blr1"
#  size     = "s-1vcpu-1gb"
#  ssh_keys = ["${digitalocean_ssh_key.default.id}"]
#}

# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "web3" {
  image    = "ubuntu-18-04-x64"
  name     = "MSR-test-master"
  region   = "blr1"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}
	
