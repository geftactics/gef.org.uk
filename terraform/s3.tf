resource "aws_s3_object" "gef_env" {
  bucket       = module.gef_org_uk.bucket_id
  key          = "_/index.js"
  content      = templatefile("public_html/gef.org.uk/_/index.js.tftpl", { api_url = aws_lambda_function_url.gef_dirlist.function_url })
  content_type = "application/javascript"
}


resource "aws_s3_bucket" "revolve" {
  bucket = "www.${var.domain_revolve}"
}


resource "aws_s3_bucket_public_access_block" "revolve" {
  bucket = aws_s3_bucket.revolve.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_ownership_controls" "revolve" {
  bucket = aws_s3_bucket.revolve.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_acl" "revolve" {
  depends_on = [
    aws_s3_bucket_public_access_block.revolve,
    aws_s3_bucket_ownership_controls.revolve,
  ]
  bucket = aws_s3_bucket.revolve.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "revolve" {
  bucket = aws_s3_bucket.revolve.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.revolve.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_s3_bucket_website_configuration" "revolve" {
  bucket = aws_s3_bucket.revolve.id
  
  index_document {
    suffix = "index.html"
  }
}

