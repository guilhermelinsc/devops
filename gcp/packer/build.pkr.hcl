build {
  sources = ["source.googlecompute.webapp"]

  provisioner "shell" {
    script = "./files/configure.sh"
  }
}