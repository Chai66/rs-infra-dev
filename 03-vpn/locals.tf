locals {
  ec2_name = "${var.project_name}-${var.environment}"
  #database_subnet_ids = element(split(",",data.aws_ssm_parameter.database_subnet_ids.value),0) # split will divide 2 subnets and element will be pick the 1st subnet which mentioned as 0
  # Terraform will treat as string where as aws will treat as list in ssm parameter
}