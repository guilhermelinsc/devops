build {
  sources = ["source.googlecompute.webapp"]

  provisioner "ansible" {
    # galaxy_file = "./ansible/requirements.yml"
    # galaxy_force_install = true

    playbook_file    = "./ansible/playbook.yml" 
    # ansible_env_vars = ["ANSIBLE_REMOTE_TMP=/tmp/.ansible/tmp" ]
    user = "packer"
    
    extra_arguments = ["-vvvv"]
  }
}