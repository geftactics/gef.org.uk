locals {
  gef_files = [
    for file in flatten(fileset("${path.module}/public_html/gef.org.uk/**", "**")) :
    trim(file, "../") 
    if length(regexall(".*\\.terragrunt-source-manifest.*", file)) == 0
  ]
}


resource "aws_s3_object" "gef" {
  for_each     = { for idx, file in local.gef_files : idx => file }
  bucket       = module.gef_org_uk.bucket_id
  key          = each.value
  source       = "${path.module}/public_html/gef.org.uk/${each.value}"
  etag         = filemd5("${path.module}/public_html/gef.org.uk/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}


resource "aws_s3_object" "gef_env" {
  bucket       = module.gef_org_uk.bucket_id
  key          = "_/index.js"
  content      = templatefile("public_html/gef.org.uk/_/index.js.tftpl", { api_url = aws_lambda_function_url.gef_dirlist.function_url })
  content_type = "application/javascript"
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