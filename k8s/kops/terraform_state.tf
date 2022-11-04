terraform {
  backend "s3" {
    bucket = "server.terraform.k8s"
    key = "states"
    region = "ap-southeast-1"
  }
}