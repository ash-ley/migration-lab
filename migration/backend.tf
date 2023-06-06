terraform {
  backend "s3" {
    bucket = "backend-onprem-migrationlab"
    key    = "migration/terraform.tfstates"
  }
}