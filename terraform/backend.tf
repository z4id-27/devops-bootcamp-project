terraform {
  backend "s3" {
    bucket = "devops-bootcamp-terraform-z4id-27"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
