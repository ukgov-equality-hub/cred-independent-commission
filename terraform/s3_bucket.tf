
// An S3 bucket to store the static website
resource "aws_s3_bucket" "static_website_s3_bucket" {
  bucket_prefix = lower("${var.service_name_hyphens}--${var.environment_hyphens}--static-site")
}

resource "aws_s3_bucket_public_access_block" "static_website_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.static_website_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "static_website_s3_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.static_website_s3_bucket.arn}/*"  // The files within the bucket
    ]
    condition {
      test = "StringEquals"
      values = [aws_cloudfront_distribution.distribution_for_s3_bucket.arn]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "static_website_s3_bucket_policy" {
  bucket = aws_s3_bucket.static_website_s3_bucket.id
  policy = data.aws_iam_policy_document.static_website_s3_policy.json
}
