variable "environment" {
  type = string
}
variable "project" {
  type = string
  default = "fleetops"
}
variable "eks_cluster_version" {
  type = string
  default = "1.30"
}
variable "eks_cluster_role_arn" {
  type = string
  default = ""
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "control_plane_sg_id" {
  type = string
}




