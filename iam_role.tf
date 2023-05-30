resource "aws_iam_role" "ec2-to-rds-iam-role" {
  name = "ec2-to-rds-iam-role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": "sts:AssumeRole",
"Principal": {
 "Service": "ec2.amazonaws.com"
},
"Effect": "Allow"
}
]
}
EOF

  tags = {
    tag-key = "ec2-to-rds-iam-role"
  }
}

resource "aws_iam_role_policy" "ec2-to-rds-policy" {
  name = "ec2-to-rds-iam-policy"
  role = aws_iam_role.ec2-to-rds-iam-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket", 
                "s3:PutObject", 
                "s3:GetObject" 
		],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-to-rds-iam-instance-profile"
  role = aws_iam_role.ec2-to-rds-iam-role.name
}