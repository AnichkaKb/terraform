resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-gitea"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "Policy for AWS CodeBuild"

    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:logs:us-east-1:323536671443:log-group:/aws/codebuild/buildapp",
          "arn:aws:logs:us-east-1:323536671443:log-group:/aws/codebuild/buildapp:*"
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::codepipeline-us-east-1-*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:codecommit:us-east-1:323536671443:gitea3"
        ],
        Action = [
          "codecommit:GitPull"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::codepipeline-us-east-1-56233797892",
          "arn:aws:s3:::codepipeline-us-east-1-56233797892/*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow",
        Action = [
       
  "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = [
          "arn:aws:codebuild:us-east-1:323536671443:report-group/buildapp-*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}


#CODEBUILD
resource "aws_codebuild_project" "buildgitea" {
  name         = "builgitea"
  build_timeout = 5

  source {
      type = "CODECOMMIT"
      location = "gitea3"
  }

  service_role = aws_iam_role.codebuild_role.arn

  environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
      type = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
  }
  artifacts {
    type                  = "S3"
    location              = var.location
    name                  = var.nameart
    packaging             = "ZIP"
    path                  = "giteapipeline/SourceArti/ZRe7z8k.zip"
    artifact_identifier   = "buildspec.yml"
  }
}

