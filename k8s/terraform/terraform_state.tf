terraform {
  backend "s3" {
    bucket = "server.terraform"
    key = "states"
    region = "ap-southeast-1"
  }
}