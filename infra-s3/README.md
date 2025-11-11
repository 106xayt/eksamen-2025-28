# infra-s3

This folder contains Terraform code to create an S3 bucket for analysis results including a lifecycle rule that only applies to the prefix `midlertidig/` (temporary files).

Key points
- Terraform >= 1.5, AWS Provider ~> 5.x
- Backend: S3 backend (bucket `pgr301-terraform-state`) — must exist before running `terraform init` with backend-config
- Lifecycle rule: objects under `midlertidig/` will be transitioned and expired according to variables

Required repository secrets for CI
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (defaults to `eu-west-1`)

Initialize (example local)

1) Ensure the remote backend bucket exists: `pgr301-terraform-state` in `eu-west-1`.

2) Init with explicit backend config (backend params cannot use TF variables):

```bash
terraform init \
  -backend-config="bucket=pgr301-terraform-state" \
  -backend-config="region=eu-west-1" \
  -backend-config="key=infra-s3/terraform.tfstate"
```

3) Plan and apply (example):

```bash
# optional overrides via environment
export TF_VAR_bucket_name="kandidat-28-data"
export TF_VAR_days_to_glacier=14
export TF_VAR_days_to_expire=30

terraform fmt -check
terraform validate
terraform plan -out=plan.tfplan
terraform apply "plan.tfplan"
```

Destroy (if needed):

```bash
terraform destroy
```

Notes and assumptions
- Default `bucket_name` is `kandidat-28-data` — please override in CI or by setting `TF_VAR_bucket_name`.
- The lifecycle rule explicitly targets objects with prefix `midlertidig/`. Objects outside that prefix are not affected.
- The backend S3 bucket `pgr301-terraform-state` must already exist (create manually if required).
# infra-s3

This folder contains Terraform code to create an S3 bucket for analysis results including a lifecycle rule that only applies to the prefix `midlertidig/` (temporary files).

Key points
- Terraform >= 1.5, AWS Provider ~> 5.x
- Backend: S3 backend (bucket `pgr301-terraform-state`) — must exist before running `terraform init` with backend-config
- Lifecycle rule: objects under `midlertidig/` will be transitioned and expired according to variables

Required repository secrets for CI
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (defaults to `eu-west-1`)

Initialize (example local)

1) Ensure the remote backend bucket exists: `pgr301-terraform-state` in `eu-west-1`.

2) Init with explicit backend config (backend params cannot use TF variables):

```bash
terraform init \
  -backend-config="bucket=pgr301-terraform-state" \
  -backend-config="region=eu-west-1" \
  -backend-config="key=infra-s3/terraform.tfstate"
```

3) Plan and apply (example):

```bash
# optional overrides via environment
export TF_VAR_bucket_name="my-candidate-data"
export TF_VAR_days_to_glacier=14
export TF_VAR_days_to_expire=30

terraform fmt -check
terraform validate
terraform plan -out=plan.tfplan
terraform apply "plan.tfplan"
```

Destroy (if needed):

```bash
terraform destroy
```

Notes and assumptions
- Default `bucket_name` is `kandidat-28-data` — please override in CI or by setting `TF_VAR_bucket_name`.
- The lifecycle rule explicitly targets objects with prefix `midlertidig/`. Objects outside that prefix are not affected.
- The backend S3 bucket `pgr301-terraform-state` must already exist (create manually if required).
