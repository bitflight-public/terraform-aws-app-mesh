


module "dynamic_subnets" {
  source                  = "../../terraform-aws-dynamic-subnets"
  context                 = "${module.label.context}"
  region                  = "${data.aws_region.current.name}"
  availability_zones      = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"] // Optional list of AZ's to restrict it to
  vpc_id                  = "${module.vpc.vpc_id}"
  igw_id                  = "${module.vpc.igw_id}"
  public_subnet_count     = "2"                                                                      // Two public zones for the load balancers
  private_subnet_count    = "3"                                                                      // Four private zones for the 
  map_public_ip_on_launch = "true"

  ## You can use nat_gateway_enabled or nat_instance_enabled
  ## It creates one nat instance per public subnet.
  ## So if you want to exclude the public subnet by setting the public_subnet_count to 0
  ## You will neet to use the nat_gateway_enabled option.
  nat_instance_enabled = "false"

  nat_gateway_enabled = "true"
}

## VPC module doesn't have the latest version of null_label 
## module integrated with it at the time of this example being 
## written so no context variable here.
module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.1"
  namespace  = "${module.label.namespace}"
  stage      = "${module.label.environment}"
  name       = "${module.label.name}"
  attributes = ["${module.label.attributes}"]
  delimiter  = "${module.label.delimiter}"
  tags       = "${module.label.tags}"
  cidr_block = "${var.vpc_cidr}"
}

data "aws_region" "current" {}



variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

provider "aws" {
  version                     = "~> 2.12"
  region                      = "us-east-2"
  skip_requesting_account_id  = true        # this can be tricky
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
