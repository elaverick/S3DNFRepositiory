variable "region" {
  type = string
  default = "eu-west-2"
}

variable "s3_name" {
  type = string
}

variable "domain_name" {
  type = string
  default = ""  
}

variable "hosted_zone_id" {
  type = string
}

variable "repo_path" {
  type = string
}

variable "content_types" {
  default = {
    "html" = "text/html"
    "htm" = "text/html"
    "png" = "image/png"
    "gif" = "image/gif"
    "jpg" = "image/jpeg"
    "jpeg" = "image/jpeg"
    "css" = "text/css"
    "js" = "text/js"
    "xml" = "application/xml"
    "bz2" = "application/x-bzip2"
    "gz" = "application/gzip"
    "asc" = "application/pgp-signature"
    # Add more key-value pairs as needed
  }
}
