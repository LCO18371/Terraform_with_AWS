resource "aws_iam_policy" "codebuild_policy" {
  name   = "${var.AppName}-codebuild-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "*", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_iam_policy" "cloudformation_policy" {
  name   = "${var.AppName}-cloudformation-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "*", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudformation_attach" {
  role       = aws_iam_role.cloudformation_role.name
  policy_arn = aws_iam_policy.cloudformation_policy.arn
}

resource "aws_iam_policy" "codepipeline_policy" {
  name   = "${var.AppName}-codepipeline-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "*", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

