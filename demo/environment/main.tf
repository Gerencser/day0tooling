# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretaccesskey}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  tags = {
    Name = "main"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demo.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "demo" {
  vpc_id                  = "${aws_vpc.demo.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
  tags = {
    Name = "demo"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "demo elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.demo.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "demo" {
  name        = "application"
  description = "Used for application network"
  vpc_id      = "${aws_vpc.demo.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "demo1" {
  name = "DemoApplicationElb1"

  subnets         = ["${aws_subnet.demo.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = [aws_instance.application1.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "demo2" {
  name = "DemoApplicationElb2"

  subnets         = ["${aws_subnet.demo.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = [aws_instance.application1.id, aws_instance.application2.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "demo3" {
  name = "DemoApplicationElb3"

  subnets         = ["${aws_subnet.demo.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = [aws_instance.application1.id, aws_instance.application2.id, aws_instance.application3.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "application1" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "application1"
  }

  instance_type = "t2.micro"

  availability_zone = "eu-west-1b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-0b3fed455ce6b3d9a"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.demo.id}"
  private_ip = "10.0.1.101"
}

resource "aws_instance" "application2" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "application2"
  }

  instance_type = "t2.micro"

  availability_zone = "eu-west-1b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-0b3fed455ce6b3d9a"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.demo.id}"
  private_ip = "10.0.1.102"
}

resource "aws_instance" "application3" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "application3"
  }

  instance_type = "t2.micro"

  availability_zone = "eu-west-1b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-0b3fed455ce6b3d9a"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.demo.id}"
  private_ip = "10.0.1.103"
}

resource "aws_instance" "db" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"
    host = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  tags = {
    Name = "database"
  }

  instance_type = "t2.micro"

  availability_zone = "eu-west-1b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-0713f98de93617bb4"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.demo.id}"
  private_ip = "10.0.1.200"

  provisioner "file" {
    source      = "../database/database.sql"
    destination = "/home/ec2-user/database.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install mariadb-server mariadb",
      "sudo service mariadb start",
      "sleep 20s",
      "mysql -u root --force < database.sql"
    ]
  }
}



