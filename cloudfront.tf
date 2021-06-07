#bucket containing the static files to serve out
resource "aws_s3_bucket" "bcgov-parks-reso-public" {
  bucket = var.s3_bucket
  acl    = "private"

  tags   = {
    Name = var.s3_bucket_name
  }
}

#bucket to hold cloudfront logs
resource "aws_s3_bucket" "parks-reso-public-logs" {
  bucket = "parks-reso-public-logs"
  acl    = "private"

  tags   = {
    Name = "${var.s3_bucket_name} Logs"
  }
}

resource "aws_cloudfront_origin_access_identity" "parks-reso-public-oai" {
  comment = "Cloud front OAI for BC Parks reservations public delivery"
}

#setup a cloudfront distribution to serve out the frontend files from s3 (github actions will push builds there)
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bcgov-parks-reso-public.bucket_regional_domain_name
    origin_id   = var.s3_origin_id
    origin_path = "/${var.app_version}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.parks-reso-public-oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.parks-reso-public-logs.bucket_domain_name
    prefix          = "logs"
  }

  # aliases = ["dev.parks-reso-public.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = var.target_env
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}