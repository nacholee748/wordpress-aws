# RDS

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group-wordpress"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "Wordpress DB subnet group"
  }
}

resource "aws_db_instance" "wordpress-bd" {
  allocated_storage    = var.allocated_storage
  instance_class       = var.db_instance_class
  engine               = "mysql"
  engine_version       = "8.0"
  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true

  # Security Group
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Backup & Maintenance
  backup_retention_period = 7
  multi_az               = false
  storage_encrypted      = true

  # Tags
  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
    Project = "${var.Project}"
  }

  # Enable deletion protection (optional, for production environments)
  deletion_protection = false
}

# Security Group for the RDS Instance
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_sg_wordpress"
  description = "RDS Sg"
  vpc_id      = "${module.vpc.vpc_id}"

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
