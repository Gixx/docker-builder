# Docker Builder #

An automated script that creates a PHP 7.1 + nginx + MySQL Docker VM for your PHP7 GitHub project. This script is created for Unix-based systems.

## Requirements for OSX ##
[![Minimum Docker Version](https://img.shields.io/badge/Docker%20Toolbox-%3E%3D1.10-blue.svg)](https://www.docker.com/products/docker-toolbox)
[![Minimum Virtualbox Version](https://img.shields.io/badge/VirtualBox-%3E%3D5.1.10-blue.svg)](https://www.virtualbox.org/wiki/Downloads?replytocom=98578)

**`IMPORTANT! The VirtualBox 5.1.8 and some earlier editions like 5.0.28 has issues with "docker pull" command. See` [VirtualBox](https://www.virtualbox.org/ticket/16084) `website for more details.`**

## Project Setup ##
1) Download the `install.sh` into the directory where you want to store your project's source, e.g.: `~/Projects/myproject`. 

* In the following I will refer the project as `myproject`, but you can give any name.

```bash
mkdir -p ~/Projects/myproject && cd ~/Projects/myproject/
curl -sL https://raw.githubusercontent.com/Gixx/docker-builder/master/install.sh > ./install.sh
/bin/bash ./install.sh 
```

2) The script will ask for some basic informantion during the installation.

For the demo, I cloned [my own project](https://github.com/Gixx/WebHemi) but still refer as `myproject`. You can name it as you wish when the installer asks for the `VM NAME`.

![docker-builder_01](https://cloud.githubusercontent.com/assets/87073/21842521/7ba6cf70-d7e7-11e6-8bfb-61622a697384.png)

* The installer will download and install `composer` into the `/usr/bin/` folder of the FPM container.
* If your GitHub project has a `composer.json` file, the installer will automatically run the `composer install` command in the FPM container.

3) If everything works fine, you will get a message in the end like below. Add the IP address to the `/etc/hosts` file.

![docker-builder_02](https://cloud.githubusercontent.com/assets/87073/21842460/262c15a0-d7e7-11e6-93f0-3fff7e05fb60.png)

4) Create the database schema from console or with your favourite SQL GUI (like MySQL Workbench).
```bash
$> eval $(docker-machine env myproject)
$> docker exec -it myproject-dbms bash
root@42eb77011507:/opt/project# mysql -uroot -prootpass myprojectdatabase < /opt/project/path/to/myproject.schema.sql
```

* Note: the container ID will be different for you.
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

## PhpStorm Setup ##

In the following I will give a small tutorial, how to configure the project with PhpStorm.

**IMPORTANT: On the screenshots I modified my actual home folder path to `~/`. You shouldn't do that, so please leave it as the PhpStorm provides it by default.**

### Create the project ###

* Choose the `New Project from Existing Files...` option on the startup screen or from the `File` menu.

![docker-builder_03](https://cloud.githubusercontent.com/assets/87073/21843368/0a020926-d7eb-11e6-8355-41819e285c01.png)

* We will configure everithing manually. Choose the `sources` folder and mark it as `Project Root`.

![docker-builder_04](https://cloud.githubusercontent.com/assets/87073/21843370/0a040e24-d7eb-11e6-8ea6-bd56f789a772.png)

* Optional: With the `File > Rename Project...` you can give a better name for the project without renaming the `source` folder itself.

![docker-builder_05](https://cloud.githubusercontent.com/assets/87073/21843369/0a037266-d7eb-11e6-9b2c-8fcc2c37b33c.png)

* Optional: Mark the directories of your project by their functions. 

![docker-builder_06](https://cloud.githubusercontent.com/assets/87073/21843373/0a06a616-d7eb-11e6-940b-db369aa633ab.png)

### Configure the Docker machine ###

* Open the project Preferences and navigate to the `Build, Execution, Deployment > Docker` option. 
* Press the `+` to add a new Docker setup. 
* Check the `Import credentials from Docker Machine` option. If this is your only Docker project, the it will select automatically, otherwise you have to select the correct one.

![docker-builder_07](https://cloud.githubusercontent.com/assets/87073/21843371/0a05e050-d7eb-11e6-88a2-dc40c7072237.png)

### Configure the PHP environment ###

* Open the project Preferences and navigate to the `Languages & Frameworks > PHP` option.
* Set the `PHP language level` to `7.1`.
* Press the `...` button to add a new `CLI Interpreter`.

![docker-builder_08](https://cloud.githubusercontent.com/assets/87073/21843372/0a063226-d7eb-11e6-8de6-0ab3eb43882a.png)

* Choose the `Remote...` option.

![docker-builder_09](https://cloud.githubusercontent.com/assets/87073/21843374/0a198452-d7eb-11e6-8928-9e496d5d30cb.png)

* Select the previously set up Docker machine. 
* If the image name is not `php:7.1-fpm` then select it from the dropdown list.
* Press the [ OK ] button, then you have to see the correct setup. Note that it recognized the Xdebug as well.

![docker-builder_10](https://cloud.githubusercontent.com/assets/87073/21843375/0a1d5992-d7eb-11e6-9fc0-688aeab48013.png)

* Optional: It is recommended to check the `Visible only for this project` option.
* The PHP Interpreter setup is complete.

![docker-builder_11](https://cloud.githubusercontent.com/assets/87073/21843376/0a201894-d7eb-11e6-8ebf-ed33d61f16aa.png)

* Note that the docker-builder is designed to use the PhpStorm's default `/opt/project` mappings, so you don't have to deal with the paths here.

![docker-builder_12](https://cloud.githubusercontent.com/assets/87073/21844249/2663c890-d7ee-11e6-9865-b07def94a88c.png)

### Configure the PHP server ###

* Open the project Preferences and navigate to the `Languages & Frameworks > PHP > Servers` option.
* Give a name to be able to identify it when needed.
* For the `Host` give the same value as you gave during the `docker-builder` setup.
* Check the `Use path mappings` option and in the `Absolute path on the server` column add `/opt/project` value manually.

![docker-builder_13](https://cloud.githubusercontent.com/assets/87073/21844612/a0542e0a-d7ef-11e6-96c6-e58e42617046.png)

### Configure Composer packages ###

* If your project has a `composer.json` you can get the PhpStorm to add the defined packages to the library.

Unfortunately the PhpStorm's current release (version 2016.3.2) doesn't support the remote interpreter for this tool, so if you want to use is - which is recommended - you have to either install the PHP locally.
For more information about how to do it, please visit the [official PHP website](https://www.php.net).

* Open the project Preferences and navigate to the `Languages & Frameworks > PHP > Composer` option.
* Choose the local PHP interpreter. If you don't have it listed, you can set it up by clicking the [ ... ] button.
* Browse 

![docker-builder_16](https://cloud.githubusercontent.com/assets/87073/21847426/2728143a-d7fc-11e6-9fca-01e4478c3ae2.png)

### Configure the PHP Code Sniffer ###

* If your project has a `composer.json` with the corresponding package then you can refer them in the configuration.

```javascript
{
    "require-dev": {
        "squizlabs/php_codesniffer": "^2.6"
    }
}
```

* Open the project Preferences and navigate to the `Build, Execution, Deployment > PHP > Code Sniffer` option and set a Local Interpreter.
* No need to waste time with remote interpreters, the PhpStorm's built-in interpreter is far enough. 

```bash
# Note to change the ~ to the absolute path of the Projects folder
~/Projects/myproject/sources/vendor/bin/phpcs
```

![docker-builder_14](https://cloud.githubusercontent.com/assets/87073/21845733/0fe82c0e-d7f4-11e6-97ac-428ee43bf988.png)

* Open the project Preferences and navigate to the `Editor > Inpections` option and enable the `PHP Code Sniffer validation` under the `PHP` section. 
* If your project has your own phpcs configuration, set the `Coding standard` to `Custom` and browse the file.
* Note that the file name must be `ruleset.xml`.

![docker-builder_14b](https://cloud.githubusercontent.com/assets/87073/21847113/6e44a5ba-d7fa-11e6-83b0-8ee77b251096.png)


### Configure the PHP Mess Detector ###

* If your project has a `composer.json` with the corresponding package then you can refer them in the configuration.

```javascript
{
    "require-dev": {
        "phpmd/phpmd": "^2.4"
    }
}
```

* Open the project Preferences and navigate to the `Build, Execution, Deployment > PHP > Mess Detector` option and set a Local Interpreter.
* No need to waste time with remote interpreters, the PhpStorm's built-in interpreter is far enough.

```bash
# Note to change the ~ to the absolute path of the Projects folder
~/Projects/myproject/sources/vendor/bin/phpmd
```

![docker-builder_15](https://cloud.githubusercontent.com/assets/87073/21847042/11199bb6-d7fa-11e6-995f-1fc82c7927df.png)

* Open the project Preferences and navigate to the `Editor > Inpections` option and enable the `PHP Mess Detector validation` under the `PHP` section. 
* If your project has your own phpmd configuration, add it by pressing the `+` button under the `Custom rulesets:` section.
* The filename can be anything, `phpmd.xml` is recommended.

![docker-builder_15b](https://cloud.githubusercontent.com/assets/87073/21847254/32352cb0-d7fb-11e6-9666-30d4f4b5234c.png)

### Configure PHPUnit ###

* If your project has a `composer.json` with the corresponding package then you can refer them in the configuration.

```javascript
{
    "require-dev": {
        "phpunit/phpunit": "5.7.4"
    }
}
```

* Open the project Preferences and navigate to the `Languages & Frameworks > PHP > PHPUnit` option.
* Click the `+` and select the `By Remote Interpreter` option.

![docker-builder_17a](https://cloud.githubusercontent.com/assets/87073/21847829/4463c466-d7fe-11e6-8269-02d1276848ec.png)

* Select the PHP 7.1 interpreter we created earlier.

![docker-builder_17b](https://cloud.githubusercontent.com/assets/87073/21847830/4465fbbe-d7fe-11e6-8dc8-a5d6c549ed4e.png)

* In the `PHPUnit library` section, choose the `Use Composer autoloader` option. It the path is not set automatically, type:

```bash
/opt/project/vendor/autoload.php
```
* If your project has its custom PHPUnit configuration - recommended -, check the `Default configuration file` option and add its path. Unfortunately there's no "Browse" button, so you have to type it manully.
* Here's a [sample configuration XML](https://raw.githubusercontent.com/Gixx/WebHemi/master/phpunit.xml)

```bash
/opt/project/xdebug.xml
```

![docker-builder_17c](https://cloud.githubusercontent.com/assets/87073/21847831/447c80be-d7fe-11e6-9d5d-67990ce0bee8.png)

* On the toolbar there's a dropdown list. Note that is might be empty if you didn't set anything up before. Choose the `Edit Configurations...` option.

![docker-builder_17d](https://cloud.githubusercontent.com/assets/87073/21848209/05290ef8-d800-11e6-8447-bb14ae7a3d4c.png)

* By pressing the `+` choose to add `PHPUnit`. Beware: do not choose the `PHPUnit by HTTP` now.
* Add a custom name for this setup.
* If your project has its custom PHPUnit configuration - recommended -, choose the `Defined in the configuration file` option and browse the file.

![docker-builder_17e](https://cloud.githubusercontent.com/assets/87073/21848210/052b13f6-d800-11e6-91c8-5b9f85907b83.png)

* On the toolbar press the green "Play" button and wait for the miracle.

![docker-builder_17f](https://cloud.githubusercontent.com/assets/87073/21848391/c46c1468-d800-11e6-84e7-af6c49b54edb.png)
