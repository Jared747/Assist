terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_db_instance" "assist" {
  identifier        = "assist-${var.environment}"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  skip_final_snapshot = true
}

output "db_endpoint" {
  value = aws_db_instance.assist.endpoint
}
