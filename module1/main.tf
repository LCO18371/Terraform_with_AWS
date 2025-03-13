terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_codebuild_project" "build" {
  name         = "codebuild-${var.AppName}"
  description  = "CodeBuild project for ${var.AppName}"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = var.CodeBuildImage
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.BuildSpecFileNameForAPI
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.AppName}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "aws-cloudtrail-logs--inventory"
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn        = "arn:aws:codeconnections:us-east-1:008893372207:connection/3a79559b-dda5-4bc4-bc67-3bc0a3acd502"
        BranchName           = var.GitHubRepoBranch
        FullRepositoryId     = "LCO18371/multibranch-sample-app"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"
    
    # Action Group 1: Create ChangeSet
    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      version         = "1"
      input_artifacts = ["BuildArtifact", "SourceArtifact"]
      configuration = {
        StackName           = "${var.AppName}-serverless-stack"
        ActionMode          = "CHANGE_SET_REPLACE"
        RoleArn             = aws_iam_role.cloudformation_role.arn
        ChangeSetName       = "pipeline-changeset"
        Capabilities        = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_NAMED_IAM"
        TemplatePath        = "BuildArtifact::${var.SAMOutputFile}"
        TemplateConfiguration = "SourceArtifact::${var.ParametersFile}"
      }
    }

    # Action Group 2: Manual Approval
    action {
      name       = "ManualApproval"
      category   = "Approval"
      owner      = "AWS"
      provider   = "Manual"
      version    = "1"
    }

    # Action Group 3: Execute ChangeSet
    action {
      name            = "ExecuteChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      version         = "1"
      input_artifacts = ["BuildArtifact", "SourceArtifact"]
      configuration = {
        StackName     = "${var.AppName}-serverless-stack"
        ActionMode    = "CHANGE_SET_EXECUTE"
        RoleArn       = aws_iam_role.cloudformation_role.arn
        ChangeSetName = "pipeline-changeset"
      }
    }
  }

  # Other pipeline stages can go here...
}

  # stage {
  #   name = "Deploy-CreateChangeSet"
  #   action {
  #     name            = "CreateChangeSet"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "CloudFormation"
  #     version         = "1"
  #     input_artifacts = ["BuildArtifact", "SourceArtifact"]
  #     configuration = {
  #       StackName           = "${var.AppName}-serverless-stack"
  #       ActionMode          = "CHANGE_SET_REPLACE"
  #       RoleArn             = aws_iam_role.cloudformation_role.arn
  #       ChangeSetName       = "pipeline-changeset"
  #       Capabilities        = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_NAMED_IAM"
  #       TemplatePath        = "BuildArtifact::${var.SAMOutputFile}"
  #       TemplateConfiguration = "SourceArtifact::${var.ParametersFile}"
  #     }
  #   }
  # }

  # stage {
  #   name = "Approval"
  #   action {
  #     name       = "ManualApproval"
  #     category   = "Approval"
  #     owner      = "AWS"
  #     provider   = "Manual"
  #     version    = "1"
  #   }
  # }

  # stage {
  #   name = "Deploy-ExecuteChangeSet"
  #   action {
  #     name            = "ExecuteChangeSet"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "CloudFormation"
  #     version         = "1"
  #     input_artifacts = ["BuildArtifact", "SourceArtifact"]
  #     configuration = {
  #       StackName     = "${var.AppName}-serverless-stack"
  #       ActionMode    = "CHANGE_SET_EXECUTE"
  #       RoleArn       = aws_iam_role.cloudformation_role.arn
  #       ChangeSetName = "pipeline-changeset"
  #     }
  #   }
  # }

# Outputs
output "codebuild_role_arn" {
  value       = aws_iam_role.codebuild_role.arn
  description = "ARN of the IAM role used by CodeBuild."
}

output "codepipeline_role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "ARN of the IAM role used by CodePipeline."
}

output "codepipeline_name" {
  value       = aws_codepipeline.pipeline.name
  description = "Name of the AWS CodePipeline."
}
