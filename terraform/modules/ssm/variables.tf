variable "environment" {
  type = string
}
variable "project" {
  type = string
  default = "fleetops"
}
variable "redis_endpoint" {
  type = string
  description = "ElastiCache primary endpoint"
}
variable "cors_allowed_origins" {
  type = string
  description = "Comma-separated CORS origins"
  default = "https://fleetops.website"
}
variable "app_base_url" {
  type = string
  description = "Public URL e.g. https://fleetops.website"
}




