variable "domain_name" {
  description = "The domain name for the CloudFront distribution"
  type        = string
}

variable "origin_domain_name" {
  description = "The domain name of the origin"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}
