terraform {
  backend "s3"{
    bucket = "for-terraform-statefile-backend"
    key = "statefile-storage-key"
    dynamodb_table = "for-statefile-locking"
    region = var.region
  }
}