variable "env" {
  type = "map"
  default = {
    staging = "staging"
    production = "production"
  }
}

variable "region" {
  type = "map"
  default = {
    staging = "us-west-2"
    production = "ap-southeast-1"
  }
}

variable "zones" {
  type = "map"
  default = {
    staging = [
      "us-west-2a"]
    production = [
      "ap-southeast-1a",
      "ap-southeast-1b",
      "ap-southeast-1c"]
  }
}

variable "k8_cluster_rs" {
  type = "map"
  default = {
    staging = {
      master = {
        machine_type = "t2.medium"
        min_size = 1
        max_size = 1
      }
      node = {
        machine_type = "t2.large"
        min_size = 3
        max_size = 5
      }
    }
    production = {
      master = {
        machine_type = "t2.large"
        min_size = 1
        max_size = 1
      }
      node = {
        machine_type = "t2.medium"
        min_size = 3
        max_size = 4
      }
    }
  }
}

variable "kops_non_masq_cidr" {
  type = "map"
  default = {
    staging = "100.64.0.0/10"
    production = "100.64.0.0/10"
  }
}

variable "vpc_cidr" {
  type = "map"
  default = {
    staging = "172.20.0.0/16"
    production = "14.0.0.0/16"
  }
}

variable "vpc_private_subnets" {
  type = "map"
  default = {
    staging = [
      "172.20.32.0/24"]
    production = [
      "14.0.1.0/24",
      "14.0.2.0/24",
      "14.0.3.0/24",]
  }
}

variable "vpc_public_subnets" {
  type = "map"
  default = {
    staging = [
      "172.20.0.0/24"]
    production = [
      "14.0.101.0/24",
      "14.0.102.0/24",
      "14.0.103.0/24",]
  }
}
