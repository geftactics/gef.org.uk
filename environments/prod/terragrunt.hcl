# Terraform configuration to use
terraform {
  source = "${get_parent_terragrunt_dir()}/terraform/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Specfic variables for this environment
inputs = {
  domain_squiggle = "squiggle.org"
  domain_gef = "gef.org.uk"
  domain_revolve = "r-evolve.net"
  domain_kendal = "kendal.me"
}
