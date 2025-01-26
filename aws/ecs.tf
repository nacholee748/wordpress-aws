### ECS
resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster-wordpress"

tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}

data "template_file" "wordpress-td" {
  template = "${file("task_definitions/wordpress-td.json")}"

  vars = {
    db_host = "${aws_ssm_parameter.database-host.value}"
    db_user = "${aws_ssm_parameter.database-user.value}"
    db_pass = "${aws_ssm_parameter.database-master-password.value}"
    db_name = "${aws_ssm_parameter.database-name.value}"
    efs-id = "${aws_efs_file_system.efs-wordpress.id }"
  }
}

resource "aws_ecs_task_definition" "wordpress-app" {
  family                   = "wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn            = "${aws_iam_role.ecs_task_assume_role.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"

  container_definitions = "${data.template_file.wordpress-td.rendered}"
}

# log group
resource "aws_cloudwatch_log_group" "webapp" {
  name = "awslogs-wordpress"

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}

resource "aws_ecs_service" "wordpress-app" {
  name            = "wordpress-app"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.wordpress-app.arn}"
  desired_count   = "${var.webapp_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = module.vpc.private_subnets
  }

  # load_balancer {
  #   target_group_arn = "${aws_alb_target_group.webapp.id}"
  #   container_name   = "wordpress"
  #   container_port   = "${var.webapp_port}"
  # }
  enable_execute_command = true
#   depends_on = [
#     "aws_alb_listener.http_webapp",
#   ]
  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "wordpress-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.webapp_port}"
    to_port         = "${var.webapp_port}"
    security_groups = ["${aws_security_group.lb_http.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}

resource "aws_efs_file_system" "efs-wordpress" {
  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
    Name = "efs-fargate"
  }
}

resource "aws_efs_mount_target" "mount1" {
  file_system_id = aws_efs_file_system.efs-wordpress.id
  subnet_id      = module.vpc.private_subnets[0]
}

resource "aws_efs_mount_target" "mount2" {
  file_system_id = aws_efs_file_system.efs-wordpress.id
  subnet_id      = module.vpc.private_subnets[1]
}