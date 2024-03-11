#---------------------------------
# S3 Bucket
#---------------------------------
resource "aws_s3_bucket" "dnfrepo" {
  bucket = var.s3_name
}

#---------------------------------
# S3 Bucket ACL
#---------------------------------
resource "aws_s3_bucket_acl" "dnfrepo" {
  depends_on = [
    aws_s3_bucket.dnfrepo,
    aws_s3_bucket_ownership_controls.dnfrepo
  ]

  bucket = aws_s3_bucket.dnfrepo.id
  acl    = "private"
}

#---------------------------------
# S3 Bucket Ownership Controls
#---------------------------------
resource "aws_s3_bucket_ownership_controls" "dnfrepo" {
  depends_on = [
    aws_s3_bucket.dnfrepo
  ]
  bucket = aws_s3_bucket.dnfrepo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#---------------------------------
# S3 Bucket Public Access Block
#---------------------------------
resource "aws_s3_bucket_public_access_block" "dnfrepo" {
  depends_on = [
    aws_s3_bucket.dnfrepo,
    aws_s3_bucket_acl.dnfrepo
  ]
  bucket = aws_s3_bucket.dnfrepo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#---------------------------------
# S3 Bucket Policy
#---------------------------------
resource "aws_s3_bucket_policy" "dnfrepo" {
  depends_on = [
    aws_cloudfront_distribution.dnfrepo
  ]
  bucket = aws_s3_bucket.dnfrepo.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.dnfrepo.arn}/*",
        Condition = {
          StringLike = {
            "aws:SourceArn": [
              aws_cloudfront_distribution.dnfrepo.arn
            ]
          }
        }
      },
      {
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = aws_s3_bucket.dnfrepo.arn,
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

#---------------------------------
# S3 Objects - Basic Assets
#---------------------------------
resource "aws_s3_object" "basicAssets" {
    bucket = aws_s3_bucket.dnfrepo.id

    for_each = fileset("basicAssets/","**/*.{html,htm,css,js,png,jpg,jpeg}")
    
    key = "${each.value}"
    source = "basicAssets/${each.value}"
    content_type = var.content_types[split(".",each.value)[length(split(".", each.value)) - 1]]
}

#---------------------------------
# S3 Objects - RPMs
#---------------------------------
resource "aws_s3_object" "rpms" {
    bucket = aws_s3_bucket.dnfrepo.id

    for_each = fileset(var.repo_path,"*.rpm")
    
    key = "${each.value}"
    source = "${var.repo_path}/${each.value}"
    content_type = "application/octet-stream"
}

#---------------------------------
# S3 Objects - repodata
#---------------------------------
resource "aws_s3_object" "repodata" {
    bucket = aws_s3_bucket.dnfrepo.id

    for_each = fileset("${var.repo_path}/repodata/","**/*.*")
    
    key = "repodata/${each.value}"
    source = "${var.repo_path}/repodata/${each.value}"
    content_type = var.content_types[split(".",each.value)[length(split(".", each.value)) - 1]]
}