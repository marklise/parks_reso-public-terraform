#CloudFront Roles

#Route 53 Roles & Cert roles needed??
# resource "aws_iam_role" "certRole" {
#   name = "certCreateRole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "acm.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# #Needed so Terrafrom can create cert validation, WIP
# resource "aws_iam_role_policy" "park_reso_public_certs" {
#   name = "park_reso_public_certs"
#   role = aws_iam_role.certRole.id

#   policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "acm:AddTagsToCertificate",
#           "acm:DeleteCertificate",
#           "acm:DescribeCertificate",
#           "acm:GetCertificate",
#           "acm:ListCertificates",
#           "acm:RequestCertificate"
#         ],
#         "Resource": "${aws_acm_certificate.parks_reso_cert.arn}"
#       }
#     ]
#   }
#   EOF
# }

data "aws_iam_policy_document" "parks-public-s3-policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bcgov-parks-reso-public.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.parks-reso-public-oai.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.bcgov-parks-reso-public.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.parks-reso-public-oai.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "parks-reso-public" {
  bucket = "${aws_s3_bucket.bcgov-parks-reso-public.id}"
  policy = "${data.aws_iam_policy_document.parks-public-s3-policy.json}"
}
