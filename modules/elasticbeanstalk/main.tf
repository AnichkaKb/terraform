#################################
# AWS-IAM-ROLE-POLICY #
#################################
resource "aws_iam_role" "beanstalkgitea" {
    name = "elasticrole"

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    ]

    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
   })
}
resource "aws_iam_instance_profile" "beanstalkgitea_profile" {
    name = "beanstalkprofile"
    role = aws_iam_role.beanstalkgitea.name
}


#CREATE ELASTICBEANSTALK

resource "aws_elastic_beanstalk_application" "myelasticapp" {
  name = var.myelasticapp
  description = "My Go App"
}

module "network" {
  source = "../network"
}

resource "aws_elastic_beanstalk_environment" "myelasticappenv" {
  name = var.beanstalkappenv
  application = aws_elastic_beanstalk_application.myelasticapp.name
  solution_stack_name = var.solution_stack_name

  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCID"
    value = module.network.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "True"
  }

  setting {
    namespace  = "aws:ec2:vpc"
    name       = "Subnets"
    value      = join(",", module.network.subnet_id)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalkgitea_profile.name
  }
}
