terraform {
  backend "s3" {}
}

# The backend configuration values (bucket, key, region) are supplied via
# -backend-config flags when running `terraform init`. See the README for details.