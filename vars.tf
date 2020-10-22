variable "ami-webserver" {
  type        = string
  description = "Image Amazon à utiliser pour le serveur Web"
  default     = "ami-0de12f76efe134f2f"
}

variable "instance-type-webserver" {
  type        = string
  description = "Type d'Instance à utiliser pour le serveur Web"
  default     = "t2.micro"
}

