provider "aws" {
  region = "${lookup(var.region, terraform.workspace, "us-west-2")}"
}

// terraform-aws-modules/vpc/aws in vpc-module.tf corresponding to
//  - kops Version 1.15.0 (git-9992b4055)
//  - kubectl Major:"1", Minor:"16"
// terraform_aws_module_version = "2.21.0" > edit vpc-modules.tf
locals {
  env = "${lookup(var.env, terraform.workspace, "staging")}"
  zones = "${var.zones[local.env]}"
  domain_name = "server.net"
  s3_kops_state = "${local.domain_name}.k8.${local.env}"
  kops_api_version = "kops.k8s.io/v1alpha2"
  kops_k8_version = "1.15.0"
  kops_non_masq_cidr = "${var.kops_non_masq_cidr[local.env]}"
  k8_cluster_name = "${local.env}.${local.domain_name}"
  k8_cluster_rs = "${var.k8_cluster_rs[local.env]}"
  k8_image = "kope.io/k8s-1.15-debian-stretch-amd64-hvm-ebs-2019-09-26"
  vpc_cidr = "${var.vpc_cidr[local.env]}"
  vpc_private_subnets = "${var.vpc_private_subnets[local.env]}"
  vpc_public_subnets = "${var.vpc_public_subnets[local.env]}"
  tags = {
    terraform = true
  }
}


data "aws_region" "current" {}