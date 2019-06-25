provider "aws" {
  version                     = "~> 2.12"
  region                      = "us-east-2"
  skip_requesting_account_id  = true        # this can be tricky
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
