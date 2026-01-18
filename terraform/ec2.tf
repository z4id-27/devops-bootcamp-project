data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name (optional)."
  default     = null
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  private_ip                  = "10.0.0.5"
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "devops-web" }
}

resource "aws_eip" "web_eip" {
  domain = "vpc"
  tags   = { Name = "devops-web-eip" }
}

resource "aws_eip_association" "web_eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web_eip.id
}

resource "aws_instance" "ansible_controller" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  private_ip                  = "10.0.0.135"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = { Name = "devops-ansible-controller" }
}

resource "aws_instance" "monitoring" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  private_ip                  = "10.0.0.136"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = { Name = "devops-monitoring" }
}
