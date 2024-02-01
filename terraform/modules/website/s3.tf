resource "aws_s3_bucket" "this" {
  bucket = "www.${var.domain}"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.cloudfront_oac.json
}