resource "aws_s3_object" "gef_env" {
  bucket       = module.gef_org_uk.bucket_id
  key          = "_/index.js"
  content      = templatefile("public_html/gef.org.uk/_/index.js.tftpl", { api_url = aws_lambda_function_url.gef_dirlist.function_url })
  content_type = "application/javascript"
}