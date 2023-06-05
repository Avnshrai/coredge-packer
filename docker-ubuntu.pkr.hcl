packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
  changes = [
    "EXPOSE 80",
    "CMD [\"/usr/sbin/nginx\", \"-g\", \"daemon off;\"]",
    "ENTRYPOINT [\"\"]",
    ]
}

variable "image_name" {
  type    = string
  default = "coredge-base-image-v22"
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y nginx"
    ]
  }
  provisioner "file" {
    source      = "banner.txt"
    destination = "/etc/motd"
  }
  provisioner "shell" {
    inline = [
      "echo '[ ! -z \"$TERM\" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' >> /etc/bash.bashrc",
    ]
  }
  post-processor "docker-tag" {
  repository = "coredge/ubuntu-packer"
  tags = ["v1"]
  }
}

