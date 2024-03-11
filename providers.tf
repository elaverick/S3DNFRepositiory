provider "aws" {
  region = var.region
}

# Some resources (Lambda@Edge, Certificates, etc) must be 
# provisioned from us-east-1
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}