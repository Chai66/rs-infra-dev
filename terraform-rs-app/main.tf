# Create component Target Group 

resource "aws_lb_target_group" "component" {
  name     = "${local.name}-${var.tags.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 60
    health_check {
    path = "/health"
    port = 8080
    healthy_threshold = 2 # If it runs successfully 2 times its health
    unhealthy_threshold = 3 # # If it fails successfully 3 times its unhealthy
    timeout = 5 # If didnt get request in 5 secs then timeout
    interval = 10 # test it for very 10 seconds interval
    matcher = "200-299"  # has to be HTTP 200-299 or fails
  }
}

#Create One instance
#Provision with ansible/shell using bootstrap.sh
#stop the instance
#Take AMI
#delete the instance 
#Now create the launch template with AMI

 
module "component" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.centos8.id

  name = "${local.name}-${var.tags.component}-ami"

  instance_type          = "t2.micro"
  #key_name               = "user1"
  #monitoring             = true
  vpc_security_group_ids = [var.component_sg_id]
  #subnet_id              = element(split(",", data.aws_ssm_parameter.private_subnets_ids.value),0) 
  subnet_id              = element(var.private_subnets_ids,0)
  # It will take first subnet id bcoz in previous ALB there has to be 2 subnet ids
  iam_instance_profile = var.iam_instance_profile #"ShellScriptRoleForRoboshop" # Taken from roles in IAM service

  tags = merge( 
    var.common_tags,
    var.tags
  )
}

resource "null_resource" "component" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.component.id
  }

    # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.component.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh ${var.tags.component} ${var.environment}"
    ]
  }
}


# STOPS THE INSTANCE
resource "aws_ec2_instance_state" "component" {
  instance_id = module.component.id
  state       = "stopped"
  depends_on = [ null_resource.component ] # Instance stops based on above code 
}


# Copy AMI from Instance 

resource "aws_ami_from_instance" "component" {
  name               = "${local.name}-${var.tags.component}-${local.current_time}"
  source_instance_id = module.component.id
  depends_on = [ aws_ec2_instance_state.component ]
}

resource "null_resource" "component_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  # If ay changes done to above instance this will trigger
  triggers = {
    instance_id = module.component.id 
  }


  provisioner "local-exec" {
  command = "aws ec2 terminate-instances --instance-ids ${module.component.id}"
  }

  depends_on = [ aws_ami_from_instance.component]
}

# LAUNCH TEMPLATE CREATION USING THE ABOVE COPIED AMI

resource "aws_launch_template" "component" {
  name = "${local.name}-${var.tags.component}"

  image_id = aws_ami_from_instance.component.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  update_default_version = true

vpc_security_group_ids = [var.component_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.component}"
    }
  }
}

#AUTO SCALING - Input for Auto scaling is launch template


resource "aws_autoscaling_group" "component" {
  name                      = "${local.name}-${var.tags.component}"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2 # how many instances needed
  target_group_arns         = [ aws_lb_target_group.component.arn ]
  #force_delete              = true
  #placement_group           = aws_placement_group.test.id
  #launch_configuration      = aws_launch_configuration.foobar.name
  vpc_zone_identifier       = var.private_subnets_ids

  launch_template {
    id      = aws_launch_template.component.id
    version = aws_launch_template.component.latest_version
  }  
    instance_refresh {
    strategy = "Rolling" # This will be done with out providing downtime
    preferences {
      min_healthy_percentage = 50 # Atleast half instances should be running
    }
    triggers = ["launch_template"] # A refreh is started when any of the auto scaling properties changes
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-${var.tags.component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}


resource "aws_lb_listener_rule" "component" {
  listener_arn = var.app_alb_listener_arn
  priority     = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.component.arn
  }

  condition {
    host_header {
      values = ["${var.tags.component}.app-${var.environment}.${var.zone_name}"] 
      # depends on the record created in hosted zone
    }
  }
}

resource "aws_autoscaling_policy" "component" {
   autoscaling_group_name = aws_autoscaling_group.component.name
   name                   = "${local.name}-${var.tags.component}"
   policy_type            = "TargetTrackingScaling" 

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}