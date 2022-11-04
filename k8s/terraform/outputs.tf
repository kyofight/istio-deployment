output "domain_name" {
  value = "${local.domain_name}"
}

output "region" {
  value = "${data.aws_region.current.name}"
}

output "vpc_cidr" {
  value = "${local.vpc_cidr}"
}

output "private_subnet_cidr" {
  value = "${local.vpc_private_subnets}"
}

output "public_subnet_cidr" {
  value = "${local.vpc_public_subnets}"
}

output "availability_zones" {
  value = "${local.zones}"
}

// Needed for kops

output "kops_s3_bucket" {
  value = "${aws_s3_bucket.k8-state.bucket}"
}

output "kubernetes_cluster_name" {
  value = "${local.k8_cluster_name}"
}

output "kops_api_version" {
  value = "${local.kops_api_version}"
}

output "kops_k8_version" {
  value = "${local.kops_k8_version}"
}

output "kops_non_masq_cidr" {
  value = "${local.kops_non_masq_cidr}"
}

output "kops_k8_cluster_rs" {
  value = "${local.k8_cluster_rs}"
}

output "kops_k8_image" {
  value = "${local.k8_image}"
}

