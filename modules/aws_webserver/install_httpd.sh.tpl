#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=curl http://169.254.169.254/latest/meta-data/local-ipv4
echo "<h1>Welcome to ACS730 ${prefix}! FINAL PROJECT <font color="turquoise"> in ${env} environment. </font></h1><br> Built using Terraform, AWS, Ansible and GIT!"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd