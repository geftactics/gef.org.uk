module "gef_org_uk" {
  source      = "./modules/website"
  environment = var.environment
  domain      = var.domain_gef
  r53_zone    = "gef.org.uk"
}

module "squiggle_org" {
  source      = "./modules/website"
  environment = var.environment
  domain      = var.domain_squiggle
  r53_zone    = "squiggle.org"
}