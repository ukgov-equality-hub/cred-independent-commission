
resource "aws_cloudfront_cache_policy" "cloudfront_cache_policy_for_s3_bucket" {
  name = "${var.service_name_hyphens}--${var.environment_hyphens}-Cache-Policy"
  min_ttl = 0
  default_ttl = 60
  max_ttl = 600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "distribution_for_s3_bucket" {

  comment = "${var.service_name_hyphens}--${var.environment_hyphens}"

  origin {
    domain_name = aws_s3_bucket.static_website_s3_bucket.bucket_regional_domain_name
    origin_id = "${var.service_name_hyphens}--${var.environment_hyphens}--S3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_for_s3_bucket.id
  }

  price_class = "PriceClass_100"

  aliases = ["${var.dns_record_subdomain_including_dot}${data.aws_route53_zone.cred_dot_independent_commission_dot_uk_zone.name}"]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.certificate_validation_waiter.certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }

  default_root_object = "index.html"

  enabled = true
  is_ipv6_enabled = true

  default_cache_behavior {
    cache_policy_id = aws_cloudfront_cache_policy.cloudfront_cache_policy_for_s3_bucket.id
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${var.service_name_hyphens}--${var.environment_hyphens}--S3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }
}

resource "aws_cloudfront_origin_access_control" "oac_for_s3_bucket" {
  name                              = "${var.service_name_hyphens}--${var.environment_hyphens}--oac_for_s3_bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
