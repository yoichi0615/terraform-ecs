resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.env}-website-bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
