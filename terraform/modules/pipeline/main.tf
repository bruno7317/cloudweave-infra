resource "aws_s3_bucket" "artifact_store" {
  bucket_prefix = var.app_name
  force_destroy = true
}

resource "aws_ecr_repository" "app" {
  name         = var.app_name
  force_delete = true
}

resource "aws_iam_role" "codepipeline_role" {
  name_prefix = "${var.app_name}-codepipeline"
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

resource "aws_iam_policy" "codepipeline_policies" {
  name_prefix = "${var.app_name}-codepipeline-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "${aws_s3_bucket.artifact_store.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["codestar-connections:UseConnection"],
        Resource = var.github_codestar_connection_arn
      },
      {
        Effect   = "Allow",
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policies.arn
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix = "${var.app_name}-codebuild"
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

resource "aws_iam_policy" "codebuild_policy" {
  name_prefix = "${var.app_name}-codebuild-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.artifact_store.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_codebuild_project" "project" {
  name         = "${var.app_name}-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
  }

  environment {
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/standard:5.0"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
    }

    environment_variable {
      name  = "REPOSITORY"
      value = aws_ecr_repository.app.name
    }
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      version          = "1"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      output_artifacts = ["SourceOutput"]
      configuration = {
        ConnectionArn    = var.github_codestar_connection_arn
        FullRepositoryId = var.github_repository_id
        BranchName       = var.github_main_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "BuildAction"
      category        = "Build"
      version         = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceOutput"]
      configuration = {
        ProjectName = aws_codebuild_project.project.name
      }
    }
  }
}
