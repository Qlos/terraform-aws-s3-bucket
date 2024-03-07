<!-- BEGIN_TF_DOCS -->
## Documentation


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [time_sleep.wait_for_aws_s3_bucket_settings](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Set to `false` to disable the blocking of new public access lists on the bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Set to `false` to disable the blocking of new public policies on the bucket. | `bool` | `true` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.<br>Deprecated by AWS in favor of bucket policies.<br>Automatically disabled if `bucket_object_ownership` is set to "BucketOwnerEnforced".<br>Defaults to "private" for backwards compatibility, but we recommend setting `bucket_object_ownership` to "BucketOwnerEnforced" instead. | `string` | `null` | no |
| <a name="input_bucket_grants"></a> [bucket\_grants](#input\_bucket\_grants) | A list of policy grants for the bucket, taking a list of permissions.<br>Conflicts with `bucket_acl`. Set `bucket_acl` to `null` to use this.<br>Deprecated by AWS in favor of bucket policies.<br>Automatically disabled if `bucket_object_ownership` is set to "BucketOwnerEnforced". | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the bucket. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_bucket_object_ownership"></a> [bucket\_object\_ownership](#input\_bucket\_object\_ownership) | Specifies the S3 object ownership control.<br>Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'.<br>'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket.<br>'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL.<br>'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL.<br>Defaults to "ObjectWriter" for backwards compatibility, but we recommend setting "BucketOwnerEnforced" instead. | `string` | `"ObjectWriter"` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | A bucket policy in JSON format | `string` | `""` | no |
| <a name="input_encryption_enabled"></a> [encryption\_enabled](#input\_encryption\_enabled) | Boolean to enable server-side encryption for S3 bucket. | `bool` | `false` | no |
| <a name="input_encryption_master_kms_key"></a> [encryption\_master\_kms\_key](#input\_encryption\_master\_kms\_key) | AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of `encryption_sse_algorithm` as `aws:kms`<br>When empty in use is default aws/s3 AWS KMS master key provided by AWS. | `string` | `""` | no |
| <a name="input_encryption_sse_algorithm"></a> [encryption\_sse\_algorithm](#input\_encryption\_sse\_algorithm) | server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | `string` | `"AES256"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Set to `false` to disable the ignoring of public access lists on the bucket. | `bool` | `true` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management.<br>Example to older objects than `60 days` to move to [GLACIER](https://aws.amazon.com/s3/storage-classes/glacier/) storage class:<pre>[<br>  {<br>    id      = "example1"<br>    enabled = true<br>    transition = [<br>      {<br>        days          = 60<br>        storage_class = "GLACIER"<br>      }<br>    ]<br>  }<br>]</pre> | `any` | `[]` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Set to `false` to disable the restricting of making the bucket public. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to bucket. | `map(string)` | `{}` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Boolean specifying enabled state of versioning or object containing detailed versioning configuration. | `bool` | `false` | no |
| <a name="input_website_enabled"></a> [website\_enabled](#input\_website\_enabled) | Enable static website hosting on bucket. | `bool` | `false` | no |
| <a name="input_website_error_document"></a> [website\_error\_document](#input\_website\_error\_document) | The name of the index document for the website. | `string` | `null` | no |
| <a name="input_website_index_document"></a> [website\_index\_document](#input\_website\_index\_document) | The name of the index document for the website. | `string` | `null` | no |
| <a name="input_website_routing_rules"></a> [website\_routing\_rules](#input\_website\_routing\_rules) | Routing rules to website in JSON format<br>Example routing rule from `KeyPrefix` equaled to `images` to `folderdeleted.html` object:<pre>[<br>    {<br>        "Condition": {<br>            "KeyPrefixEquals": "images/"<br>        },<br>        "Redirect": {<br>            "ReplaceKeyWith": "folderdeleted.html"<br>        }<br>    }<br>]</pre> | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The domain name of the bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The region-specific domain name of the bucket. |
| <a name="output_id"></a> [id](#output\_id) | The name of the bucket. |

<!-- END_TF_DOCS -->
