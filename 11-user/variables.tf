variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "tags" {
    default = {
        component = "user"
    }
  
}

variable "project_name" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "zone_name" {
  default = "devopspractice123.online"
}

variable "iam_instance_profile" {
  default = "ShellScriptRoleForRoboshop"
}