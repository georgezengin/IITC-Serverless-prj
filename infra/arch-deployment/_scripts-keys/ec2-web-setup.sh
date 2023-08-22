#!/bin/bash
echo '=========================================================================='
echo '====== Starting instance configuration ==================================='
echo '=========================================================================='
echo ''
echo '* yum update *************************************************************'
echo ''
sudo yum update -y && sudo yum upgrade -y

# echo ''
# echo '* python3 ****************************************************************'
# echo ''
# sudo yum -y install python3

# echo ''
# echo '* pip ********************************************************************'
# sudo yum -y install pip

# echo ''
# echo '* python ansible package *************************************************'
# echo ''
# python3 -m pip install ansible 

echo ''
echo '* git ********************************************************************'
echo ''
sudo yum install git -y

# echo ''
# echo '* java *******************************************************************'
# echo ''
# sudo yum -y install java 

# echo ''
# echo '* java 11 ****************************************************************'
# echo ''
# sudo amazon-linux-extras install java-openjdk11 -y

# echo ''
# echo '* get jenkins repo *******************************************************'
# echo ''
# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# echo ''
# echo '* rpm import key *********************************************************'
# echo ''
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# echo ''
# echo '* ansible2 ***************************************************************'
# echo ''
# sudo amazon-linux-extras install ansible2 -y

# echo ''
# echo '* jenkins and docker thru ansible ****************************************'
# echo ''

# #echo '* get jenkins ************************************************************'
# #sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# #sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# #sudo yum install jenkins -y

# # run ansible playbook to install jenkins
cd ~/.install.logdir
echo ''
#echo '* ansible playbook *******************************************************'
echo ''
#sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook install-jenkins.yml -vvv
echo ''
echo '* install front **********************************************************'
echo ''
unzip -o angular-cognito-app.zip -d /home/ec2-user/angular-cognito-app
sudo chmod o+x /home/ec2-user/angular-cognito-app /home/ec2-user/angular-cognito-app/*
echo ''
echo '* install nginx & start front ********************************************'
echo ''
sudo amazon-linux-extras install nginx1 -y
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.save
sudo cp nginx.conf /etc/nginx/nginx.conf
# Start Nginx
sudo systemctl start nginx
# Enable Nginx to start on boot
sudo systemctl enable nginx
echo ''
echo '* install nodejs *********************************************************'
echo ''
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts
nvm install 16
node -e "console.log('Running Node.js ' + process.version)"
echo ''
echo '* fix amazon linux permissions *******************************************'
echo ''
sudo chown root:root /home
sudo chmod 777 /home
sudo chown ec2-user:ec2-user /home/ec2-user -R
sudo chmod 701 /home/ec2-user /home/ec2-user/.ssh
sudo chmod 600 /home/ec2-user/.ssh/authorized_keys
echo ''
echo '=========================================================================='
echo '= End of instance configuration script ==================================='
echo '=========================================================================='
