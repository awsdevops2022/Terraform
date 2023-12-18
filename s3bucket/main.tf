module "s3_bucket" {
    source = "./bucket"
    bucket_name = "demo-my-first-tf-bucket"
}