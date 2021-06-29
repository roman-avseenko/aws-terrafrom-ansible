# AWS + Terraform + Ansible ***DevOps Lab***
## Requirements 
1. Python 3
2. Pipenv
3. Terraform 1.0.0
4. AWS account
5. AWS CLI (Optional)
### 1. Specify AWS IAM user(s)
For use this configuration you'll need to specify AWS IAM user(s). For Terraform I'am using profile with the name `terraform_user` (VPC and EC2 full access). And in Ansible I'm using profile with the name `ansible` (EC2 read only access).
### 2. Specify AWS Profile
You'll need to specify credentials of IAM user(s) created in paragraph 1. I'll recommend you to do this using AWS CLI, like

	aws configure --profile name
and fill your credentials. More information [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
### 3. Clone this repository
	git clone https://github.com/roman-avseenko/aws-terrafrom-ansible.git	

and go into it.
### 4. Setup environment
- Go into `pipenv shell`
- Run  `./install_and_deploy.sh` that install requirement packages (include Ansible collections), and execute Terraform and Ansible configuration.
> Note: this Terraform configuration creates OpenSSH private key 
### Enjoy!
