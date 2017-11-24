# Create a new instance of the latest Ubuntu 16.04 on an t2.micro node
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "tito" {
  name        = "tito"
  description = "Allow all inbound traffic from your IP address."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Adds SSH access"
  }
}

resource "aws_key_pair" "tito" {
  key_name   = "tito"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "ec2_instance" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  availability_zone      = "${var.aws_region}"
  vpc_security_group_ids = ["${aws_security_group.tito.id}"]
  key_name               = "tito"
  tags {
    Name = "titoCTF"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "echo 'tito' > /etc/hostname",
      "sudo apt-get upgrade -y",
      "sudo apt-get update -y",
      "sudo apt-get install apt-transport-https ca-certificates git vim ",
      "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB",
      "curl -sSL https://get.rvm.io | bash -s stable",
      "echo 'source /home/$USER/.rvm/scripts/rvm' >> ~/.bashrc",
      "git clone https://github.com/picatz/tito_ctf.git",
      "echo 'export SLACK_API_TOKEN=${var.slack_bot_api_token}' >> ~/.bashrc",
      "echo 'Made with ♥ by picat'"
    ]
  }
}
