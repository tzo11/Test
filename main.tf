provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_instance" "example" {
  ami           	 = "ami-0c0b74d29acd0cd97"
  instance_type 	 = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

#Attaching EBS Volume

  resource "aws_ebs_volume" "data-vol" {
     availability_zone = "us-east-1b"
     size = 10
     tags = {
        Name = "data-volume"
     }
  }

  resource "aws_volume_attachment" "example-volume" {
  device_name = "/dev/sdb"
  volume_id = "${aws_ebs_volume.data-vol.id}"
  instance_id = "${aws_instance.example.id}"
  }
