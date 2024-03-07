locals {
  # tflint-ignore: terraform_unused_declarations
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"

  bucket_acl_enabled = var.bucket_acl == "" ? false : true
  bucket_acl         = local.bucket_acl_enabled ? var.bucket_acl : null

  public_access_block_enabled = var.block_public_acls || var.block_public_policy || var.ignore_public_acls || var.restrict_public_buckets
  bucket_policy_enabled       = var.bucket_policy == "" ? false : true
  lifecycle_rules_enabled     = length(var.lifecycle_rules) == 0 ? false : true

  versioning = var.versioning ? "Enabled" : "Disabled"

  acl_grants = var.bucket_grants == null ? [] : flatten(
    [
      for g in var.bucket_grants : [
        for p in g.permissions : {
          id         = g.id
          type       = g.type
          permission = p
          uri        = g.uri
        }
      ]
  ])

  # `full_lifecycle_rule_schema` is just for documentation and cheat sheet for maintainer, not actually used.
  # tflint-ignore: terraform_unused_declarations
  full_lifecycle_rule_schema = {
    id     = null # string, must be specified and unique
    status = true # bool

    abort_incomplete_multipart_upload_days = null # number
    expiration = {
      date                         = null # string
      days                         = null # integer > 0
      expired_object_delete_marker = null # bool
    }
    transition = [{
      date          = null # string
      days          = null # integer >= 0
      storage_class = null # string/enum, one of `GLACIER`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING, `DEEP_ARCHIVE`, `GLACIER_IR`.
    }]
    noncurrent_version_expiration = {
      newer_noncurrent_versions = null # integer > 0
      noncurrent_days           = null # integer >= 0
    }
    noncurrent_version_transition = [{
      newer_noncurrent_versions = null # integer >= 0
      noncurrent_days           = null # integer >= 0
      storage_class             = null # string/enum, one of `GLACIER`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `DEEP_ARCHIVE`, `GLACIER_IR`.
    }]
    filter = [{
      id      = null # string
      enabled = true # bool
      filter  = null # list
    }]
  }
}

data "aws_canonical_user_id" "this" {}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.encryption_master_kms_key
      sse_algorithm     = var.encryption_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = tobool(local.bucket_policy_enabled) ? 1 : 0
  bucket = var.bucket_name
  policy = var.bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_acl" "this" {
  count  = (var.bucket_object_ownership != "BucketOwnerEnforced" && (local.bucket_acl != null || length(local.acl_grants) > 0)) ? 1 : 0
  bucket = var.bucket_name

  # Conflicts with access_control_policy so this is enabled if no grants
  # hack when `null` value can't be used (eg, from terragrunt, https://github.com/gruntwork-io/terragrunt/pull/1367)
  acl = try(length(local.acl_grants), 0) == 0 ? local.bucket_acl : null

  dynamic "access_control_policy" {
    for_each = try(length(local.acl_grants), 0) == 0 || try(length(local.bucket_acl), 0) > 0 ? [] : [1]

    content {
      dynamic "grant" {
        for_each = local.acl_grants

        content {
          grantee {
            id   = grant.value.id
            type = grant.value.type
            uri  = grant.value.uri
          }
          permission = grant.value.permission
        }
      }

      owner {
        id = join("", data.aws_canonical_user_id.this.id)
      }
    }
  }

  # This `depends_on` is to prevent "AccessControlListNotSupported: The bucket does not allow ACLs."
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = tobool(local.public_access_block_enabled) ? 1 : 0
  bucket = var.bucket_name

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.bucket_object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [time_sleep.wait_for_aws_s3_bucket_settings]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = var.bucket_name

  versioning_configuration {
    status = local.versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = tobool(local.lifecycle_rules_enabled) ? 1 : 0
  bucket = var.bucket_name

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled == true ? "Enabled" : "Disabled", rule.value.status == true ? "Enabled" : "Disabled")

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {}
      }

      # filter with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # filter with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_enabled ? 1 : 0
  bucket = var.bucket_name

  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }

  routing_rules = var.website_routing_rules
}

resource "time_sleep" "wait_for_aws_s3_bucket_settings" {
  depends_on       = [aws_s3_bucket_public_access_block.this, aws_s3_bucket_policy.this]
  create_duration  = "30s"
  destroy_duration = "30s"
}
