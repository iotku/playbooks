# Debian 13

## Ansible Prep

### As root
`apt install pipx`

`gpasswd -a user sudo` <-- Add user to sudo group so we can --ask-become-pass

Logout/login (or reboot)

##  as user
`pipx install --include-deps ansible` <-- must use `--include-deps` to ensure we get `ansible-playbook`

`pipx inject ansible python-debian`

`pipx ensurepath`

`source ~/.bashrc`

`ansible-playbook debian/13/main.yml --ask-become-pass` <-- enter valid sudo password
