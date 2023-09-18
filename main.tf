#NETWORK

module "network" {
  source             = "./modules/network"
}

#BEANSTALK

module "elasticbeanstalk" {
  source             = "./modules/elasticbeanstalk"
  beanstalkrole_name = "beanstalkgitea"
}

#DATABASE

module "RDS" {
  source             = "./modules/RDS"
}


#CODEBUILD

module "codebuild" {
  source             = "./modules/codebuild"
}

#CODEPIPELINE
module "codepipeline" {
  source             = "./modules/codepipeline"
}

