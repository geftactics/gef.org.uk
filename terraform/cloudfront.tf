resource "aws_cloudfront_function" "index_rewrite" {
  name    = "index-rewrite-${var.environment}"
  runtime = "cloudfront-js-2.0"
  comment = "Index.html rewrite"
  publish = true
  code    = file("${path.module}/src/index_rewrite.js")
}