# create new S3 Bucket
resource "aws_s3_bucket" "tf-demo-bucket" {
  bucket = "tf-demo-bucket-20230512"

  tags = {
    Name        = "Terraform Demo S3 Bucket"
    Environment = "Dev"
  }
}

# enable bucket versioning property
resource "aws_s3_bucket_versioning" "versioning_demo" {
  bucket = aws_s3_bucket.tf-demo-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# add access policy to the new bucket
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.tf-demo-bucket.id
  policy = data.aws_iam_policy_document.allow_acces.json
}

# allow access to bucket from another account
data "aws_iam_policy_document" "allow_acces" {
  statement {
    principals {
	  type = "AWS"
	  identifiers = ["174436502675"]
	}

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.tf-demo-bucket.arn,
      "${aws_s3_bucket.tf-demo-bucket.arn}/*"
    ]
  }
}