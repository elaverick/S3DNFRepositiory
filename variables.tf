variable "region" {
  type = string
  default = "eu-west-2"
}

variable "s3_name" {
  type = string
}

variable "repo_path" {
  type = string
}

variable "lambda_function_name" {
  type = string
  default = "dnfrepohandler"
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
    # Add more key-value pairs as needed
  }
}
