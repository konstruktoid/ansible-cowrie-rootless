# Cowrie honeypot deployment using Packer, Terraform, Ansible and Docker

![Cowrie log](./images/cowrie_aws.png "Cowrie log")

## About

This is a repository containing a [Ansible](https://www.ansible.com/) role
to deploy a [Cowrie](https://github.com/cowrie/cowrie) honeypot container
using [Docker in rootless mode](https://github.com/konstruktoid/ansible-role-docker-rootless).

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

## Setup

### ansible-pull example

```sh
$ ansible-galaxy install -r requirements.yml
$ ansible-pull -i '127.0.0.1,' -c local --url https://github.com/konstruktoid/ansible-cowrie-rootless.git local.yml
```

### AWS deployment

There is a [Packer](https://www.packer.io/) configuration file, [aws/ubuntu.pkr.hcl](aws/ubuntu.pkr.hcl),
and [Terraform](https://www.terraform.io/) plan, [aws/main.tf](aws/main.tf)
available for deployment to [Amazon Web Services](https://aws.amazon.com/).

```sh
$ cd aws
$ packer init -upgrade ubuntu.pkr.hcl
$ packer validate ubuntu.pkr.hcl
$ packer build ubuntu.pkr.hcl
$ terraform init -upgrade
$ terraform validate
$ terraform plan
$ terraform apply
```

Note that the `sshd` service is disabled and replaced with the honeypot.

You will need to manage the instance using the AWS Session manager.

### Azure deployment

There is a [Packer](https://www.packer.io/) configuration file, [azure/ubuntu.pkr.hcl](azure/ubuntu.pkr.hcl),
and [Terraform](https://www.terraform.io/) plan, [azure/main.tf](aws/main.tf)
available for deployment to [Microsoft Azure](https://portal.azure.com/).

The `azure_vars_export` file is available in the [konstruktoid/hardened-images](https://github.com/konstruktoid/hardened-images/blob/master/azure_vars_export)
repository.

```sh
$ export ARM_PRINCIPAL_NAME=Honeypots
$ export ARM_RESOURCE_GROUP_NAME=Honeypots
$ export ARM_LOCATION=northeurope
$ source azure_vars_export
$ packer init -upgrade ubuntu.pkr.hcl
$ packer validate ubuntu.pkr.hcl
$ packer build ubuntu.pkr.hcl
$ terraform init -upgrade
$ terraform validate
$ terraform import "azurerm_resource_group.honeypots" \
  "$(az group show --name "${ARM_RESOURCE_GROUP_NAME}" | jq -r '.id')"
$ terraform plan
$ terraform apply
$ grep -E '"admin_(username|password)":' terraform.tfstate

Note that the `sshd` service is disabled and replaced with the honeypot.

You will need to manage the instance using the serial console.

### DigitalOcean deployment

There is a [Packer](https://www.packer.io/) configuration file, [digitalocean/ubuntu.pkr.hcl](digitalocean/ubuntu.pkr.hcl),
and [Terraform](https://www.terraform.io/) plan, [digitalocean/main.tf](digitalocean/main.tf)
available for deployment to [DigitalOcean](https://www.digitalocean.com/).

```sh
$ cd digitalocean
$ packer init -upgrade ubuntu.pkr.hcl
$ export DIGITALOCEAN_TOKEN=$DO_TOKEN
$ packer validate ubuntu.pkr.hcl
$ packer build ubuntu.pkr.hcl
$ terraform init -upgrade
$ terraform validate
$ terraform plan -var "do_token=$DO_TOKEN"
$ terraform apply -var "do_token=$DO_TOKEN"
```

Note that the `sshd` service is disabled and replaced with the honeypot.

You will need to manage the instance using the Recovery Console and login
using the username set by the `system_user` packer variable,
`kondig` by default.
