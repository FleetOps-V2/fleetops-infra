variable "environment" {
  type = string
}
variable "project" {
  type = string
  default = "fleetops"
}
variable "aws_region" {
  type = string
  default = "us-east-1"
}
variable "cluster_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "oidc_provider_url" {
  type = string
  description = "OIDC provider URL without https:// (from eks/oidc output)"
}




