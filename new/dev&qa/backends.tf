terraform {
  backend "s3" {
    bucket         = "terraform-workspace-backend"
    key            = "workspace-statefile"
    region         = "us-east-1"
    dynamodb_table = "for-statefile-locking"
  }
}
