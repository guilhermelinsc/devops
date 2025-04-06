build {
  sources = ["source.googlecompute.webapp"]

  provisioner "ansible" {
    playbook_file    = "./ansible/playbook.yml" 
    user = "packer"
    
    extra_arguments = [
      "--scp-extra-args", "'-O'", // "-vvvv"
    ]
  }
}