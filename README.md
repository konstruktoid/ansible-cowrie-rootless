# Cowrie honeypot on AWS using Terraform, Ansible and Docker

![Cowrie log](./images/cowrie_aws.png "Cowrie log")

## About

This is a repository containing a [Ansible](https://www.ansible.com/) role
to deploy a [Cowrie](https://github.com/cowrie/cowrie) honeypot container
using [Docker in rootless mode](https://github.com/konstruktoid/ansible-docker-rootless).

There is a [Packer](https://www.packer.io/) configuration file, [terraform/image.pkr.hcl](terraform/image.pkr.hcl),
and [Terraform](https://www.terraform.io/) plan, [terraform/main.tf](terraform/main.tf)
available for deployment to [Amazon Web Services](https://aws.amazon.com/).

It is used to gather additional passwords and usernames for the password lists
used by
[konstruktoid/ansible-role-hardening](https://github.com/konstruktoid/ansible-role-hardening/blob/master/templates/usr/share/dict/passwords.list.j2)
and [konstruktoid/hardening](https://github.com/konstruktoid/hardening/blob/master/misc/passwords.list).

## Usage

### ansible-pull example

```sh
$ ansible-galaxy install konstruktoid.docker_rootless
$ ansible-pull -i '127.0.0.1,' -c local --url https://github.com/konstruktoid/ansible-cowrie-rootless.git local.yml
```

### AWS deployment

```sh
$ packer build image.pkr.hcl
$ terraform apply
```

Note that the `sshd` service is disabled and you will need to manage the
instance using the AWS Session manager.
