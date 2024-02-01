resource "aws_s3_bucket" "this" {
  bucket = "www.${var.domain}"
}


resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.cloudfront_oac.json
}


locals {
  site_files = [
    for file in flatten(fileset("${path.module}/../../public_html/${var.zone}/**", "**")) :
    trim(file, "../") 
    if length(regexall(".*\\.terragrunt-source-manifest.*", file)) == 0
  ]
}


resource "aws_s3_object" "this" {
  for_each     = { for idx, file in local.site_files : idx => file }
  bucket       = aws_s3_bucket.this.id
  key          = each.value
  source       = "${path.module}/../../public_html/${var.zone}/${each.value}"
  etag         = filemd5("${path.module}/../../public_html/${var.zone}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}





locals {
  mime_types = {
    ".html" = "text/html"
    ".css" = "text/css"
    ".js" = "application/javascript"
    ".ico" = "image/vnd.microsoft.icon"
    ".jpg" = "image/jpeg"
    ".png" = "image/png"
    ".svg" = "image/svg+xml"
  }
}