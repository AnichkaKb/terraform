module "codebuild" {
  source = "../codebuild"
}
module "elasticbeanstalk" {
  source = "../elasticbeanstalk"
  beanstalkrole_name = "beanstalkgitea"
}


resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-2policy"
  description = "Policy for S3 access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::tracking-app-artifact-bucket",
          "arn:aws:s3:::tracking-app-artifact-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "giteapipeline" {
  name         = "apppipeline"

  assume_role_policy = jsonencode({

    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "giteapipeline_2" {
  name       = "AmazonS3FullAccess"
  roles      = [aws_iam_role.giteapipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "giteapipeline_1" {
  name       = "AWSCodeBuildAdminAccess"
  roles      = [aws_iam_role.giteapipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_policy_attachment" "giteapipeline_6" {
  name       = "AmazonCloudWatchEvidentlyFullAccess"
  roles      = [aws_iam_role.giteapipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudWatchEvidentlyFullAccess"
}

resource "aws_iam_policy_attachment" "giteapipeline_7" {
  name       = "AdministratorAccess-AWSElasticBeanstalk"
  roles      = [aws_iam_role.giteapipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

resource "aws_iam_policy_attachment" "giteapipeline_8" {
  name       = "AmazonDMSCloudWatchLogsRole"
  roles      = [aws_iam_role.giteapipeline.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "myapp2bucket"
  acl    = "private"
}


resource "aws_codepipeline" "tracking_app_codepipeline" {
    name = "pipelinename"
    role_arn = aws_iam_role.giteapipeline.arn

    artifact_store {
        type     = "S3"
        location = aws_s3_bucket.artifact_bucket.bucket
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



#GITHUB 2
            configuration = {
                Owner      = var.ownerGit
                Repo       = var.repo
                Branch     = var.branch
                OAuthToken = var.Gittoken
            }
        }
    }




    stage {
        name = "Build"  # Новий крок для обробки артефактів "source" та створення "build"

        action {
            name            = "Build"
            category        = "Build"
            owner           = "AWS"
            provider        = "CodeBuild"
            input_artifacts = ["source"]
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
            input_artifacts = ["build"]
            version         = "1"
        configuration = {
            ApplicationName = module.elasticbeanstalk.myelasticapp
            EnvironmentName = module.elasticbeanstalk.myelasticappenv
        }
     }
   }

}
