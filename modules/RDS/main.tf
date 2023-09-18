module "network" {
  source = "../network"
}

resource "aws_security_group" "security_gitea" {
  vpc_id = module.network.vpc_id
  name = "security_gitea"
  description = "Allow inbound mysql traffic"
}
resource "aws_security_group_rule" "inbound_rule" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = aws_security_group.security_gitea.id
    source_security_group_id = aws_security_group.security_gitea.id
}
resource "aws_security_group_rule" "outgoing-rule" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.security_gitea.id
    cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_db_instance" "databasegitea" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t3.micro"
  identifier           = "databasegitea"
  vpc_security_group_ids = [aws_security_group.security_gitea.id]
  username             = var.user
  password             = var.pass

  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.gitea-sub_group.name


  tags = {
    Name = "my-rds-instance"
  }
}


resource "aws_db_subnet_group" "gitea-sub_group" {
    name = "gitea-sub_group"
    description = "RDS subnet group"
    subnet_ids = [module.network.PrivateDbSubnet, module.network.PrivateAppSubnet, module.network.PrivateAppSubnet2]

} 
