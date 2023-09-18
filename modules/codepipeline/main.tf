module "codebuild" {
  source = "../codebuild"
}

module "elasticbeanstalk" {
  source = "../elasticbeanstalk"
  beanstalkrole_name = "beanstalkgitea"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_codepipeline" "codepipelinegitea" {
    name = "codepipelinegitea"
    role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "s3://codepipeline-us-east-1-56233797892"
    type     = "S3"
  }

    stage {
        name = "Source"

        action {
            name     = "Source"
            category = "Source"
            owner    = "ThirdParty"
            provider = "GitHub"
            version  = "1"
            output_artifacts = ["source"]


#GITHUB 1
            configuration = {
                Owner      = var.ownerGit
                Repo       = var.repo
                Branch     = var.branch
                OAuthToken = var.Gittoken
            }
        }
    }




    stage {
        name = "Build"

        action {
            name            = "Build"
            category        = "Build"
            owner           = "AWS"
            provider        = "CodeBuild"
            output_artifacts = ["build"]
            version         = "1"
            configuration = {
                ProjectName = module.codebuild.codebuild

            }
         }
    }


    stage {
        name = "Deploy"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "ElasticBeanstalk"
            version         = "1"
        configuration = {
            ApplicationName = module.elasticbeanstalk.myelasticapp
            EnvironmentName = module.elasticbeanstalk.myelasticappenv
        }
     }
   }

}
