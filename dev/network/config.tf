terraform {
  backend "s3" {
    bucket = "acs730-final-project-group7-dev"    // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                     // Region where bucket created
  }
}
