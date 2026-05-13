aws_region = "us-east-1"
environment = "dev"

vpc_cidr           = "10.0.0.0/16"
app_subnet_cidr    = "10.0.1.0/24"
data_subnet_cidr_a = "10.0.3.0/24"
data_subnet_cidr_b = "10.0.4.0/24"

db_name     = "placey"
db_username = "placey_admin"

tags = {
  Team  = "team-4"
  Owner = "guillermo.romero@iteso.mx"
}
