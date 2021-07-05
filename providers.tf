provider "aws" {
   region = "ap-south-1"
}

terraform {
   backend "s3" {
      bucket = "tf-bucket-vpc"
      key = "myapp/state.tfstate"
      region = "ap-south-1"
 }
}
