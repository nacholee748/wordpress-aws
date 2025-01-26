### ALB
resource "aws_alb" "main" {
  name            = "wordpress-alb"
  subnets         = module.vpc.public_subnets
  security_groups = ["${aws_security_group.lb_http.id}"]

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}

resource "aws_alb_target_group" "webapp" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "http_webapp" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.webapp.id}"
    type             = "forward"
  }
}

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb_http" {
  name        = "wordpress-ecs-alb-http"
  description = "controls access to the ALB"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }
}
