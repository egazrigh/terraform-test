provider "aws" {
  region = "eu-west-3"
}

/*
resource "aws_iam_user" "example" {
  count = 3
  name  = "neo.${count.index}"
}
*/
variable "user_names" {
  description = "Create IAM users with theses names"
  type        = "list"
  default     = ["userOne", "UserTwo", "UserThree", "UserFour"]
}

resource "aws_iam_user" "example2" {
  count = "${length(var.user_names)}"
  name  = "${element(var.user_names,count.index)}"
}

output "Example2_users_ARN" {
  value = "${aws_iam_user.example2.*.arn}"
}

output "User2_arn" {
  #value = "${aws_iam_user.example2.1.arn}"            #marche pas
  value = "${element(aws_iam_user.example2.*.arn,1)}"
}

# 1) Create the policy document definition
data "aws_iam_policy_document" "ec2_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

# 2) define the iam  policy based on the policy document definition
resource "aws_iam_policy" "ec2_read_only" {
  name   = "ec2-read-only"
  policy = "${data.aws_iam_policy_document.ec2_read_only.json}"
}

# 3) Attach the policy to user
resource "aws_iam_user_policy_attachment" "ec2-access" {
  count      = "${length(var.user_names)}"
  user       = "${element(aws_iam_user.example2.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.ec2_read_only.arn}"
}
