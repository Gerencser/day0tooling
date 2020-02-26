# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretaccesskey}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "jenkins" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  tags = {
    Name = "jenkins"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "jenkins" {
  vpc_id = "${aws_vpc.jenkins.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "jenkins_internet_access" {
  route_table_id         = "${aws_vpc.jenkins.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.jenkins.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "jenkins" {
  vpc_id                  = "${aws_vpc.jenkins.id}"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
  tags = {
    Name = "jenkins"
  }
}

resource "aws_security_group" "jenkins" {
  name        = "application"
  description = "Used for application network"
  vpc_id      = "${aws_vpc.jenkins.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["00.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "jenkins" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "jenkins"
  }

  instance_type = "t2.micro"

  availability_zone = "eu-west-1b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-0713f98de93617bb4"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.jenkins.id}"
  private_ip = "10.0.1.200"

  provisioner "file" {
    source      = "../database/database.sql"
    destination = "/home/ec2-user/database.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install mariadb-server mariadb",
    ]
  }
}



