terraform {
  backend "s3" {
    bucket         = "tf-backend-onprem-migrationlab"
    key            = "terraform.tfstates"
  }
}