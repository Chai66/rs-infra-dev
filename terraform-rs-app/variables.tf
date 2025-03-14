variable "common_tags" {
  default = {
    # Project     = "roboshop"
    # Environment = "dev"
    # Terraform   = "true"
  }
}

variable "tags" {
    # default = {
    #     component = "catalogue"
    # }
  
}

variable "project_name" {
 # default = "roboshop"
}
variable "environment" {
 # default = "dev"
}
variable "zone_name" {
 # default = "devopspractice123.online"
}

variable "vpc_id" {

}

variable "component_sg_id" {

}

variable "private_subnets_ids" {

}

variable "iam_instance_profile" {

}

variable "app_alb_listener_arn" {

}

variable "rule_priority" {

}