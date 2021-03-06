# Cowrie honeypot on AWS using Terraform, Ansible and Docker

![Cowrie log](./images/cowrie_aws.png "Cowrie log")

## About

This is a repository containing a [Ansible](https://www.ansible.com/) role
to deploy a [Cowrie](https://github.com/cowrie/cowrie) honeypot container
using [Docker in rootless mode](https://github.com/konstruktoid/ansible-docker-rootless).

There is a [Packer](https://www.packer.io/) configuration file, [aws/ubuntu.pkr.hcl](aws/ubuntu.pkr.hcl),
and [Terraform](https://www.terraform.io/) plan, [aws/main.tf](aws/main.tf)
available for deployment to [Amazon Web Services](https://aws.amazon.com/).

It is used to gather additional passwords and usernames for the password lists
used by
[konstruktoid/ansible-role-hardening](https://github.com/konstruktoid/ansible-role-hardening/blob/master/templates/usr/share/dict/passwords.list.j2)
and [konstruktoid/hardening](https://github.com/konstruktoid/hardening/blob/master/misc/passwords.list).

The list with gathered passwords and usernames are available in the [konstruktoid/honeypot-passwords](https://github.com/konstruktoid/honeypot-passwords)
repository.

## Variables and defaults

```yaml
docker_user: cowrie
rootful_enabled: true
```

`docker_user` sets the username of the account that will run the container if
in rootless mode and the `cowrie` configuration and logs will be stored in the
user home directory, `{{ docker_user_info.home }}/cowrie`.

`rootful_enabled` will start the container as the root user and use
`--net=host`. This is required in order to gather the source address of the
attack.

## Usage

### ansible-pull example

```sh
$ ansible-galaxy install konstruktoid.docker_rootless
$ ansible-pull -i '127.0.0.1,' -c local --url https://github.com/konstruktoid/ansible-cowrie-rootless.git local.yml
```

### AWS deployment

```sh
$ cd aws
$ packer build ubuntu.pkr.hcl
$ terraform apply
```

Note that the `sshd` service is disabled and you will need to manage the
instance using the AWS Session manager.
