 #CODE_BUILD

resource "aws_s3_bucket" "artifact_bucket" {
    bucket = "rolebuild"
}

resource "aws_iam_policy" "codebuild_start_build_policy" {
  name        = "codebuild-start"
  description = "Policy to allow starting CodeBuild builds"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "codebuild:StartBuild",
      Effect   = "Allow",
      Resource = "arn:aws:codebuild:us-east-1:323536671443:project/giteatracking"
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "cloudwatch-policy"
  description = "Policy to allow CloudWatch Logs actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "logs:CreateLogStream",
      Effect   = "Allow",
      Resource = "arn:aws:logs:us-east-1:323536671443:log-group:/aws/codebuild/giteatracking:log-stream:*"
    }]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name         = var.codebuild_project_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy_attachment" "codebuild_role1" {
  name       = "AmazonS3FullAccess"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "codebuild_role2" {
  name       = "AWSCodeBuildAdminAccess"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_policy_attachment" "codebuild_role3" {
  name       = "AdministratorAccess-AWSElasticBeanstalk"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

resource "aws_iam_policy_attachment" "codebuild_role4" {
  name       = "codebuild-start-build-attachment"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.codebuild_start_build_policy.arn
}

resource "aws_iam_policy_attachment" "codebuild_role5" {
  name       = "cloudwatch-logs-attachment"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_policy_attachment" "codebuild_role6" {
  name       = "AmazonAPIGatewayPushToCloudWatchLogs"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_policy_attachment" "codebuild_role7" {
  name       = "AmazonCloudWatchEvidentlyFullAccess"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudWatchEvidentlyFullAccess"
}
resource "aws_iam_policy_attachment" "codebuild_role9" {
  name       = "AmazonEC2FullAccess"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy_attachment" "codebuild_role10" {
  name       = "CloudWatchEventsFullAccess"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}



resource "aws_codebuild_project" "tracking_app_build" {
  name         = "buildapp"
  build_timeout = "5"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
      type = "CODEPIPELINE"
  }

  cache {
      type     = "S3"
      location = "myappbucket"
  }
  source {
      type = "CODEPIPELINE"
      buildspec = "buildspec.yml"
  }

  environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
      type = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
  }

  source_version = "main"
}
