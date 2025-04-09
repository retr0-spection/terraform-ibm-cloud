variable "ssh_key" {}

resource "ibm_resource_group" "resourceGroup" {
  name     = "default"
}

resource "ibm_is_vpc" "example_vpc" {
  name           = "example-vpc"
  resource_group = ibm_resource_group.resourceGroup.id
}

resource "ibm_is_subnet" "example_subnet" {
  name            = "example-subnet"
  vpc             = ibm_is_vpc.example_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/18"
}

resource "ibm_is_security_group" "example_sg" {
  name           = "example-sg"
  vpc            = ibm_is_vpc.example_vpc.id
}

resource "ibm_is_security_group_rule" "example_sg_rule" {
  group     = ibm_is_security_group.example_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_ssh_key" "example_ssh" {
  name       = "example-ssh"
  public_key = var.ssh_key
}

data "ibm_is_image" "ubuntu" {
    name = "ibm-ubuntu-24-04-2-minimal-amd64-1"
}

resource "ibm_is_instance" "example_vpc_instance" {
  name           = "example-instance"
  vpc            = ibm_is_vpc.example_vpc.id
  zone           = "us-south-1"
  keys           = [ibm_is_ssh_key.example_ssh.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = "bx2-2x8"
  resource_group = ibm_resource_group.resourceGroup.id
  primary_network_interface {
    subnet = ibm_is_subnet.example_subnet.id
  }
}
