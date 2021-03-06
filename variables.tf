variable "region" {
    type = string
    default = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default = 8080
}

variable "bucket" {
  type = string
}
