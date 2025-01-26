
resource "aws_iam_role" "ssm_role" {
  name               = "ssm-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "attach-ssm-policy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.ssm_role.name]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.ssm_role.name
}

# Security Group for the RDS Instance
resource "aws_security_group" "bastion_instance_sg" {
  name_prefix = "bastion_instance_sg"
  description = "Bastion Sg"
  vpc_id      = "vpc-0e9f13ae48e57cd7e" #"${module.vpc.vpc_id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
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
