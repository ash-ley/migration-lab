terraform {
  required_version = "1.4.6"
  backend "s3" {
    bucket = "backend-onprem-migrationlab"
    key    = "terraform.tfstates"
  }
}
