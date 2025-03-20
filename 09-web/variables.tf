variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "tags" {
    default = {
        component = "web"
    }
  
}

variable "project_name" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "zone_name" {
  default = "devopspilot.online"
}