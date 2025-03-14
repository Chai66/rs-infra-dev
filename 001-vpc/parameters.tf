resource "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.environment}/vpc_id"
    type = "String"
    value = module.roboshop.vpc_id
}

resource "aws_ssm_parameter" "public_subnets_ids" {
    name = "/${var.project_name}/${var.environment}/public_subnets_ids"
    type = "StringList"
    value = join(",",module.roboshop.public_subnets_ids) # join function separated by "," in a list format
}

resource "aws_ssm_parameter" "private_subnets_ids" {
    name = "/${var.project_name}/${var.environment}/private_subnets_ids"
    type = "StringList"
    value = join(",",module.roboshop.private_subnets_ids) # join function separated by "," in a list format
}

resource "aws_ssm_parameter" "database_subnets_ids" {
    name = "/${var.project_name}/${var.environment}/database_subnets_ids"
    type = "StringList"
    value = join(",",module.roboshop.database_subnets_ids) # join function separated by "," in a list format
}