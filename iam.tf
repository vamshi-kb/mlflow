data "aws_iam_policy_document" "iam-policy-eks-doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

module "iam_assumable_role" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                  = "~> 4"
  create_role              = true
  role_name                = "${var.name}"
  custom_role_trust_policy = data.aws_iam_policy_document.iam-policy-eks-doc.json
  custom_role_policy_arns  = var.iam_policies_arns

  number_of_custom_role_policy_arns = 2
 
}