variable "ami-webserver" {
  type        = string
  description = "Image Amazon à utiliser pour le serveur Web"
  default     = "ami-0de12f76efe134f2f"
}

variable "webservers-user" {
  type        = string
  description = "Nom utilisateur SSH pour les serveurs web"
  default     = "ec2-user"
}

variable "instance-type-webserver" {
  type        = string
  description = "Type d'Instance à utiliser pour le serveur Web"
  default     = "t2.micro"
}

variable "ami-bastion" {
  type        = string
  description = "Image Amazon à utiliser pour le Bastion SSH"
  default     = "ami-0de12f76efe134f2f"
}

variable "bastion-user" {
  type        = string
  description = "Nom utilisateur SSH pour le bastion"
  default     = "ec2-user"
}

variable "instance-type-bastion" {
  type        = string
  description = "Type d'Instance à utiliser pour le Bastion SSH"
  default     = "t2.micro"
}

variable "aws-local-pub-key" {
  type        = string
  description = "Clé publique locale pour créer une AWS Key Pair"
}

variable "private_key_file" {
  type = string
  description = "Chemin complet du fichier contenant la cle privee"
}

variable "database-name" {
  type        = string
  description = "Nom de la base de données à créer"
  default     = "terraform"
}

variable "database-username" {
  type        = string
  description = "Nom utilisateur pour connexion à la BD"
  default     = "terraform"
}

variable "database-password" {
  type        = string
  description = "Password utlisateur pour connexion à la BD"
  default     = "alinuxien"
}
