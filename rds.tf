# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags = {
    Name = "default vpc"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create a default subnet in the first az if one does not exit
resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

# create a default subnet in the second az if one does not exit
resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

# create security group for the web server
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver security group"
  description = "enable http access on port 80"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "webserver security group"
  }
}

# create security group for the database
resource "aws_security_group" "tf_rds_mssql_security_group" {
  name        = "tf rds mssql security group"
  description = "enable mssql access on port 1433"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "mssql access"
    from_port        = 1433
    to_port          = 1433
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "tf rds mssql security group"
  }
}

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "tf_db_subnet_group" {
  name         = "tf-db-subnets"
  subnet_ids   = [aws_default_subnet.subnet_az1.id, aws_default_subnet.subnet_az2.id]
  description  = "subnets for db instance"

  tags   = {
    Name = "tf db subnets"
  }
}

# create the rds instance
resource "aws_db_instance" "tf_db_instance" {
  engine                  = "sqlserver-ex"
  engine_version          = "15.00.4236.7.v1"
  multi_az                = false
  identifier              = "tf-dev-rds-mssql"
  username                = "admin"
  password                = "admin123"
  instance_class          = "db.t3.small"
  allocated_storage       = 20
  license_model           = "license-included"
  db_subnet_group_name    = aws_db_subnet_group.tf_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.tf_rds_mssql_security_group.id]
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  skip_final_snapshot     = true
}