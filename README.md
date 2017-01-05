# Docker Builder #

An automated script that creates a PHP7 + nginx + MySQL Docker VM for your PHP7 GitHub project. This script is created for Unix-based systems.

## Requirements for OSX ##
[![Minimum Docker Version](https://img.shields.io/badge/Docker%20Toolbox-%3E%3D1.10-blue.svg)](https://www.docker.com/products/docker-toolbox)
[![Minimum Virtualbox Version](https://img.shields.io/badge/VirtualBox-%3E%3D5.1.10-blue.svg)](https://www.virtualbox.org/wiki/Downloads?replytocom=98578)

**`IMPORTANT! The VirtualBox 5.1.8 and some earlier editions like 5.0.28 has issues with "docker pull" command. See` [VirtualBox](https://www.virtualbox.org/ticket/16084) `website for more details.`**

## Setup ##
1) Download the `install.sh` into the directory where you want to store your project's source, e.g.: `~/Projects/myGitHubProject`. 
NOTE: the folder must be empty.

```bash
mkdir -p ~/Projects/myGitHubProject && cd ~/Projects/myGitHubProject/
curl -sL https://raw.githubusercontent.com/Gixx/docker-builder/master/install.sh > ./install.sh
/bin/bash ./install.sh 
```
2) The script will ask for some basic informantion during the installation.

3) If everything works fine, you will get a message in the end like below. Add the IP address to the `/etc/hosts` file.
```bash
Put into /etc/hosts:
 172.17.0.100 myproject.dev
In new terminal before start use always:
 eval $(docker-machine env myproject)
finish
```

4) Create the database schema from console or with your favourite SQL GUI (like MySQL Workbench).
```bash
$> eval $(docker-machine env myproject)
$> docker exec -it myproject-dbms bash
root@xxxxx:/application# mysql -uroot -prootpass myprojectdatabase < /application/path/to/myproject.schema.sql
```

* Note: the ```path/to/myproject.schema.sql``` must be included in your GitHub project

5) In your PHP application use PDO to connect to the database.
```php
$conn = new PDO('mysql:dbname=myproject;charset=utf8;hostname=dbms.local', 'root', 'rootpass');
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$stmt = $conn->prepare("SELECT * FROM some_table");
$stmt->execute();
$stmt->setFetchMode(PDO::FETCH_ASSOC);
var_dump($stmt->fetchAll());
```
