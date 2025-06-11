terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

# Variables
variable "your_region" {
  default = "us-west-2"
}

variable "your_ami" {
  default = "ami-0418306302097dbff"
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile name to attach to the EC2 instance"
  default     = "LabInstanceProfile"
}

variable "your_ip" {
  default = "128.193.154.254"
}

variable "your_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhp4fVRaXWIp7PQVbIaPpEuh+yCnzIJlMG4EhVeWxZ2DZF2EfxWHMtj4sYSiRYvzGYH+9o42yojn4ojAOwI00r+hejhjcJkbriMdw9DLvq4L894gMTXdq9F20QPPAZsFlw5HVKqdByTevZruvb84dP+BrWseonGz2hczDXQga/Xr9sBS24NF4M8/lbJNpzZNWm77usaesitTN1ZfWIMs2ayZrZJZdQa8hbceGdakCR+crX2ajoj2s95EomfOlY8JNJTswBpHqzjhkKcWA1+NYfO6osFwdX7HHgh1EcyEeYOMYsZmwf7HTcf4IcH69n13pE8duX18qQnHD1syS9tfNGtl0DvgVMkC7bpBBxDMIIBzNnCujw4FASYjV3zXoSKGjWuIzgXctYovWmxOgE3WTNcT/530/HaclM+/JPBki+NcACIbTW0gFrJ0Zhb9p2Y2GI1o4ubZAqyyTPqB6j8cvS8dkfeUPH/I95rHsEc8kjgClAemj88QRpjr6IcF+8oTosz4cgNjQBEP8KWyGjK+hXAB/Z/rx9AOsQMmhH9Bd/aGNLIQp+ujRrg8ettVdyyT+dGr12UFAqq96DZA5GG0T73NkKfJOgMSJxcH47htElOsfV7zHaaYwceOrrCNQTXSFsZT7g9KeUBxRkSJowoaGiu45G4U92ZmnKfbhx6d23vw== tanya@10-248-94-156.wireless.oregonstate.edu"
}

variable "mojang_server_url" {
  default = "https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar"  # Latest Minecraft server URL
}

provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_security_group" "minecraft" {
  ingress {
    description = "SSH from home."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.your_ip}/32"]
  }
  ingress {
    description = "Minecraft from everywhere."
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Minecraft"
  }
}

resource "aws_key_pair" "home_2" {
  key_name   = "Home_2"
  public_key = var.your_public_key
}

resource "aws_instance" "minecraft" {
  ami                         = var.your_ami
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.home_2.key_name
  user_data                   = <<-EOF
    #!/bin/bash
    # Update system and install Java
    sudo yum -y update
    sudo rpm --import https://yum.corretto.aws/corretto.key
    sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
    sudo yum install -y java-21-amazon-corretto-devel.x86_64
    
    # Create Minecraft user and directory
    sudo useradd -m -r -d /opt/minecraft minecraft
    sudo mkdir -p /opt/minecraft/server
    sudo chown -R minecraft:minecraft /opt/minecraft
    
    # Download Minecraft server
    sudo -u minecraft wget -O /opt/minecraft/server/server.jar ${var.mojang_server_url}
    
    # Create startup script
    cat << 'EOS' | sudo tee /opt/minecraft/server/start.sh
    #!/bin/bash
    cd /opt/minecraft/server
    java -Xmx1024M -Xms1024M -jar server.jar nogui
    EOS
    
    sudo chmod +x /opt/minecraft/server/start.sh
    sudo chown minecraft:minecraft /opt/minecraft/server/start.sh
    
    # Accept EULA
    cat << 'EOS' | sudo -u minecraft tee /opt/minecraft/server/eula.txt
    eula=true
    EOS
    
    # Create systemd service
    cat << 'EOS' | sudo tee /etc/systemd/system/minecraft.service
    [Unit]
    Description=Minecraft Server
    After=network.target
    
    [Service]
    User=root
    WorkingDirectory=/opt/minecraft/server
    ExecStart=/opt/minecraft/server/start.sh
    Restart=always
    RestartSec=20
    
    [Install]
    WantedBy=multi-user.target
    EOS
    
    # Enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable minecraft.service
    sudo systemctl start minecraft.service
    EOF
    
  tags = {
    Name = "Minecraft"
  }
}

output "instance_ip_addr" {
  value = aws_instance.minecraft.public_ip
}