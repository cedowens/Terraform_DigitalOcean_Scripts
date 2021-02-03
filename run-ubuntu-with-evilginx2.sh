#!/bin/bash

echo "*******************************************************************"
echo "  Welcome to the Terraform Script Runner to Set Up Your C2 Infra!  "
echo "*******************************************************************"
echo ""
echo "Have you already installed terraform? (Y/N)?"
read installed

if [[ ("$installed" ==  "N") || ("$installed" == "n") ]];then
	ostype=$(uname)
	if [[ "$ostype" == "Linux" ]]; then
		echo "attempting to install terraform (linux install)..."
		curl -o ~/terraform.zip https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip
		mkdir -p ~/opt/terraform
		sudo apt install unzip
		unzip ~/terraform.zip -d ~/opt/terraform
		echo "Next add terraform to your path (append export PATH=$PATH:~/opt/terraform/bin to the end)"
		nano ~/.bashrc
		. .bashrc
	elif [[ "$ostype" == "Darwin" ]]; then
		echo "Attempting to install terraform (macOS Homebrew install)..."
		brew tap hashicorp/tap
		brew install hashicorp/tap/terraform
		
	fi
fi
echo "=====>Enter the name you want to call your droplet"
read dropletName
echo "=====>Enter the name that you want to call your firewall rule"
read firewallName
echo "=====>Enter the src IP that you will login to your C2 infra from (i.e., terraform will set up a firewall only allowing ssh/admin access in from this src IP"
read adminIP
echo "=====>Enter your Digital Ocean API key"
read DOAPIKey
echo "=====>Enter the name of your Digital Ocean ssh key (can be found in your admin console panel or you can create one there if you haven't already)"
read keyName
echo "=====>Enter the local path to the ssh private key that you use to ssh into Digital Ocean (ex: ~/.ssh/id_rsa)"
read keyPath

cd DO_new_ubuntu_with_evilginx2

sed -i -e "s/myc2-1/$dropletName/g" droplet-config-with-evilginx2.tf
sed -i -e "s/myc2rule/$firewallName/g" droplet-config-with-evilginx2.tf
sed -i -e "s/keyname/$keyName/g" init.tf
sed -i -e "s/keyname/$keyName/g" droplet-config-with-evilginx2.tf
sed -i -e "s/127.0.0.1/$adminIP/g" droplet-config-with-evilginx2.tf

terraform init
echo "====>Running terraform plan for the new droplet and firewall that the droplet will be added to"
terraform plan -var "do_token=$DOAPIKey" -var "pvt_key=$keyPath"
echo "====>Applying the terraform plan..."
terraform apply -var "do_token=$DOAPIKey" -var "pvt_key=$keyPath"
cp ini-orig init.tf
cp drop-orig droplet-config-with-evilginx2.tf
