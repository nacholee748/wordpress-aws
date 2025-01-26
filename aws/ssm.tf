resource "aws_ssm_parameter" "database-master-password" {
  name        = "/${var.environment}/database/password/master"
  description = "Datbase password"
  type        = "SecureString"
  value       = "${var.db_password}"

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "database-host" {
  name        = "/${var.environment}/database/host"
  description = "Database host"
  type        = "SecureString"
  value       = "${aws_db_instance.wordpress-bd.endpoint}"

  tags = {
    environment = "${var.environment}"
  }

  depends_on = [ aws_db_instance.wordpress-bd ]
}

resource "aws_ssm_parameter" "database-user" {
  name        = "/${var.environment}/database/user"
  description = "Datbase user"
  type        = "SecureString"
  value       = "${var.db_username}"

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "database-name" {
  name        = "/${var.environment}/database/name"
  description = "Datbase name"
  type        = "SecureString"
  value       = "${var.db_name}"

  tags = {
    environment = "${var.environment}"
  }
}
