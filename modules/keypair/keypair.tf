resource "cloudstack_ssh_keypair" "default" {
  name       = "keypair-general"
  public_key = file("~/.ssh/id_rsa.pub")
}
