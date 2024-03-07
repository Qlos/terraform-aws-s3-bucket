variable "bucket_name" {
  type        = string
  description = "Name of the bucket. If omitted, Terraform will assign a random, unique name."
}

variable "bucket_acl" {
  type        = string
  default     = null
  description = <<-EOT
    The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.
    Deprecated by AWS in favor of bucket policies.
    Automatically disabled if `bucket_object_ownership` is set to "BucketOwnerEnforced".
    Defaults to "private" for backwards compatibility, but we recommend setting `bucket_object_ownership` to "BucketOwnerEnforced" instead.
  EOT
}

variable "bucket_grants" {
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default     = []
  description = <<-EOT
    A list of policy grants for the bucket, taking a list of permissions.
    Conflicts with `bucket_acl`. Set `bucket_acl` to `null` to use this.
    Deprecated by AWS in favor of bucket policies.
    Automatically disabled if `bucket_object_ownership` is set to "BucketOwnerEnforced".
    EOT
}

variable "bucket_object_ownership" {
  type        = string
  default     = "ObjectWriter"
  description = <<-EOT
    Specifies the S3 object ownership control.
    Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'.
    'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket.
    'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL.
    'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL.
    Defaults to "ObjectWriter" for backwards compatibility, but we recommend setting "BucketOwnerEnforced" instead.
    EOT
}

variable "bucket_policy" {
  type        = string
  default     = ""
  description = "A bucket policy in JSON format"
}

variable "encryption_enabled" {
  type        = bool
  default     = false
  description = "Boolean to enable server-side encryption for S3 bucket."
}

variable "encryption_master_kms_key" {
  type        = string
  default     = ""
  description = <<-EOT
    AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of `encryption_sse_algorithm` as `aws:kms`
    When empty in use is default aws/s3 AWS KMS master key provided by AWS.
  EOT
}

variable "encryption_sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_sse_algorithm)
    error_message = "Valid values for encryption_sse_algorithm: `AES256` and `aws:kms`."
  }
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public access lists on the bucket."
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public policies on the bucket."
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the ignoring of public access lists on the bucket."
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the restricting of making the bucket public."
}

variable "website_enabled" {
  type        = bool
  default     = false
  description = "Enable static website hosting on bucket."
}

variable "website_index_document" {
  type        = string
  default     = null
  description = "The name of the index document for the website."
}

variable "website_error_document" {
  type        = string
  default     = null
  description = "The name of the index document for the website."
}

variable "website_routing_rules" {
  type        = string
  default     = null
  description = <<-EOT
    Routing rules to website in JSON format
    Example routing rule from `KeyPrefix` equaled to `images` to `folderdeleted.html` object:
    ```
    [
        {
            "Condition": {
                "KeyPrefixEquals": "images/"
            },
            "Redirect": {
                "ReplaceKeyWith": "folderdeleted.html"
            }
        }
    ]
    ```
  EOT
}

variable "versioning" {
  type        = bool
  default     = false
  description = "Boolean specifying enabled state of versioning or object containing detailed versioning configuration."
}

variable "lifecycle_rules" {
  type        = any
  default     = []
  description = <<-EOT
    List of maps containing configuration of object lifecycle management.
    Example to older objects than `60 days` to move to [GLACIER](https://aws.amazon.com/s3/storage-classes/glacier/) storage class:
    ```
    [
      {
        id      = "example1"
        enabled = true
        transition = [
          {
            days          = 60
            storage_class = "GLACIER"
          }
        ]
      }
    ]
    ```
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to assign to bucket."
}
