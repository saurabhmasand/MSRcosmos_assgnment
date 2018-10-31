1) Create two EC2 Instances in AWS Cloud using,


Additional Information


Instance Type of both instance is t2.micro
Operating System for both instances Ubuntu Server 16.04 LTS


Hostname of Instance 1 : MSR-test-Instance-1
Hostname of Instance 2 : MSR-test-Instance-2


Preferred tools but not mandatory – Terraform


Solution:


Due to suspension of my AWS account, couldn’t perform this on AWS. I’ve cleared the payment but looks like it can take 24 hours or more to restore my account. So, I’ve created two linux instances on DigitalOcean which also supports provisioning via terraform.


Steps followed in provisioning the instances (Droplets) on DigitalOcean.


A. Installing terraform:
Installing terraform from the following link:
          https://www.terraform.io/downloads.html
   
Creating ‘terraform’ folder within ~/opt:
          mkdir -p ~/opt/terraform


B. Unzipping terraform:
          unzip ~/Downloads/terraform_0.1.1_darwin_amd64.zip -d ~/opt/terraform


C. Setting env variable:


       #opening file
       vi ~/.bash_profile
       
       # adding 
       export PATH=$PATH:~/opt/terraform/bin


D. Provisioning Droplets (linux instances) using terraform:


i. Creating .tf file ‘providers.tf’ to store provider details and token key:
       
        
$ vi provider.tf     
             
provider "digitalocean" {
            token = “xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx”
        }




ii. Creating another .tf file ‘droplets.tf’ to provision two Droplets ( ‘MSR-test-Instance-1’,   ‘MSR-test-Instance-2’) along with public ssh keys for passwordless login:


$ vi droplet.tf


                
# Create a new SSH key
resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = "${file("/Users/saurabhsingh/.ssh/id_rsa.pub")}"
}


# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "web1" {
  image    = "ubuntu-18-04-x64"
  name     = "MSR-test-Instance-1"
  region   = "blr1"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${digitalocean_ssh_key.default.id}"]
}


# Create a another Droplet using the SSH key
resource "digitalocean_droplet" "web2" {
  image    = "ubuntu-18-04-x64"
  name     = "MSR-test-Instance-2"
  region   = "blr1"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${digitalocean_ssh_key.default.id}"]


}


iii. Checking terraform plan and executing terraform files to provision Droplets in DigitalOcean account:

$ terraform plan


$ terraform apply


Result:


Creates two Droplets:


1. MSR-test-Instance-1   [IP: 139.59.73.127]
2. MSR-test-Instance-2. [IP: 139.59.73.127]


Screenshot: http://prntscr.com/lc31w8


==================================End of Solution 1 ====================================



2) Once these two servers are provisioned, ensure the below following software packages are installed using configuration management tool in both the provisioned instances.


Additional Information


NVM – Version 0.33.2
Node – 8.12.0
Docker – 18.06 or latest
Docker Compose – 1.13 or latest
Openssl – latest version
Git – latest version
Preferred tools – Chef / Puppet / Salt stack / Ansible.




Solution:
--------


I’ve chosen Ansible to perform the installation and decided to create third server act as Ansible master


Created an Ansible Server on third digitalocean MSR-master [ IP: 142.93.218.101]. Performed Ansible installation on this server using following article:


https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-18-04


Ansible host are the servers created in solution 1 using terraform:
 
1. MSR-test-Instance-1   [IP: 139.59.73.127]
2. MSR-test-Instance-2. [IP: 139.59.73.127]


Ansible hosts file has been modified to have host details:


$ vi /etc/ansible/hosts


[servers]
msr1 ansible_ssh_host=139.59.73.127
msr2 ansible_ssh_host=139.59.59.191




i. Installated NVM – Version 0.33.2 and Node – 8.12.0 using Ansible Playbook:


$ cat nvmnode.yml
   
 ---
 - hosts: servers
   tasks:
     - name: Install nvm
       shell: >
           curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | sh
           creates=/home/{{ ansible_user_id }}/.nvm/nvm.sh


     - name: Install node and set version
       shell: >
           /bin/bash -c "source ~/.nvm/nvm.sh && nvm install 8.12.0 && nvm alias default 8.12.0"
           creates=/home/{{ ansible_user_id }}/.nvm/alias


$ ansible-playbook nvmnode.yml
        


Result: 
-------

root@MSR-test-Instance-2:~# nvm --version
0.33.2
root@MSR-test-Instance-2:~# node -v
v8.12.0


root@MSR-test-Instance-1:~# nvm --version
0.33.2
root@MSR-test-Instance-1:~# node -v
v8.12.0


ii. Docker – 18.06 or latest and Docker Compose – 1.13 or latest Installation using Ansible playbook on both the hosts


master@MSR-master:~/msr$ cat docker.yml 

- hosts: servers
  tasks:
  - name: Add Docker GPG key
    apt_key: url=https://download.docker.com/linux/ubuntu/gpg


  - name: Add Docker APT repository
    apt_repository:
      repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ansible_distribution_release}} stable


  - name: Install list of packages
    apt:
      name: "{{ item }}"
      state: installed
      update_cache: yes
    with_items:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common
      - docker-ce
      - docker-compose


$ ansible-playbook docker.yml

Result:
-------
For MSR-test-Instance-1   [IP: 139.59.73.127]

root@MSR-test-Instance-1:~# docker -v
Docker version 18.06.1-ce, build e68fc7a

root@MSR-test-Instance-1:~# docker-compose --version
docker-compose version 1.17.1, build unknown


For MSR-test-Instance-2. [IP: 139.59.73.127]


root@MSR-test-Instance-2:~# docker -v
Docker version 18.06.1-ce, build e68fc7a

root@MSR-test-Instance-2:~# docker-compose --version
docker-compose version 1.17.1, build unknown



iii. Openssl – latest version Installation:


Created the following ansible playbook:

master@MSR-master:~/msr$ cat openssl.yml 
---
 - hosts: servers
   tasks:
    - name: install openssl
      apt:
        name: openssl
        state: latest
        update_cache: yes

Executed the playbook:

$ ansible-playbook openssl.yml

Result:
-------

For: MSR-test-Instance-1   [IP: 139.59.73.127]

root@MSR-test-Instance-1:~# openssl version
OpenSSL 1.1.0g  2 Nov 2017


For: MSR-test-Instance-2. [IP: 139.59.73.127]

root@MSR-test-Instance-2:~# openssl version
OpenSSL 1.1.0g  2 Nov 2017


iv. Git – latest version Installation:

Created the following ansible playbook:

master@MSR-master:~/msr$ cat git.yml 

---
 - hosts: servers
   tasks:
    - name: Installing Git
      apt:
        name: git
        state: latest
        update_cache: yes

Executed the playbook:

$ ansible-playbook git.yml

Result:
-------

For: MSR-test-Instance-1   [IP: 139.59.73.127]


root@MSR-test-Instance-1:~# git --version
git version 2.17.1


For: MSR-test-Instance-2. [IP: 139.59.73.127]


root@MSR-test-Instance-1:~# git --version
git version 2.17.1




============================================End of solution 2======================================================




3) Create a Docker Container in MSR-test-Instance-1 using Docker Compose file and ensure apache web server is installed. Try to use configuration management tools to automate the entire installation of apache and deploy a sample html file from a GitHub repository.


Additional Information


You can create your own GitHub repository with a sample html file.


Preferred tools – Chef / Puppet / Salt stack / Ansible. (Note – Ansible is Preferred)


Result:
------

Implemented this requirement using a Dockerfile to build a required image, push it to docker hub and running the container using ansible playbook.


a. Implemented on: MSR-test-Instance-1   [IP: 139.59.73.127]

HTML index file:


$ cat ./docker_apache/index.html
<h2> Webpage created for MSRCORPUS assignment </h2>


Dockerfile to build the required image:


$ cat ./docker_apache/Dockerfile


FROM ubuntu
RUN apt-get update \
   && apt-get install -y apache2
COPY index.html /var/www/html/
WORKDIR /var/www/html
CMD ["apachectl", "-D", "FOREGROUND"]
EXPOSE 80


b. Ansible playbook to call dockerfile to build image and run container

$ cat apache.yml 

---
- hosts: msr1
  tasks:
    - name: Build Apache image
      docker_image:
        path: ./docker_apache
        name: saurabhsingh030892/my-apache
        push: yes


    - name: Run apache container
      docker_container:
        name: my-apache1 
        image: saurabhsingh030892/my-apache
        ports:
          - "80:80"  


Result:
------

For MSR-test-Instance-1   [IP: 139.59.73.127]

-->

root@MSR-test-Instance-1:~# curl 139.59.73.127

<h2> Webpage created for MSRCORPUS assignment </h2>


-->

root@MSR-test-Instance-1:~# docker ps


CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                NAMES
564917a90c8c        saurabhsingh030892/my-apache   "apachectl -D FOREGR…"   3 hours ago         Up 3 hours          0.0.0.0:80->80/tcp   my-apache1


--> 
You may want to directly check the public IP of the server to verify the webserver:


http://139.59.73.127/

============================================End of solution 3======================================================




4) Create a Docker Container in MSR-test-Instance-2 using Docker Compose file and ensure CouchDB Database is installed. Try to use any configuration management tool to automate the entire installation processes.


Additional Information


We should be able to access the Futon – web GUI of CouchDB, from the external system.


Preferred tools – Chef / Puppet / Salt stack / Ansible. (Note – Ansible is Preferred)


Solution:
---------

i. Created Ansible playbook  to pull custom couchdb image with futon dashboard:

---
- hosts: msr2
  tasks:
    - name: Pull couchdb Image
      docker_image:
        name: tutum/couchdb

    - name: Run couchdb container
      docker_container:
        name: couchdb1
        image: tutum/couchdb
        ports:
           - "5984:5984"

ii. Executing playbook to run the container:

$ ansible-playbook couchdb.yml

root@MSR-test-Instance-2:~/couchdb# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
be0a48d70c92        tutum/couchdb       "/run.sh"           7 minutes ago       Up 3 minutes        0.0.0.0:5984->5984/tcp   couchdb1



Result:
-------

Browser screenshot:

Browser1- couchdb successful installation 

http://139.59.59.191:5984/

Browser2- futon dashboard

http://139.59.59.191:5984/_utils/

=================================================End of solution 4 =================================================
