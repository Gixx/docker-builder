# Docker Builder v2

![Tested on Windows 10](https://img.shields.io/badge/Tested%20on-Windows%2010-green.svg)
![Tested on OSX High Sierra](https://img.shields.io/badge/Tested%20on-OSX%20High%20Sierra-green.svg)

This scripts provides a full PHP-MySQL-Nginx development environment composed by the [Docker toolbox](https://docs.docker.com/toolbox/overview/).

## Before Setup 
* edit the `VM_NAME` value in the `install.sh` script to change the project name. The default is `development`.
* edit the `docker-compose.yml` file and change the `container_name` values, the `development-network` **key**
(to: `myproject-network`, `wordress-network` etc.) and the `MYSQL_*` values.
* Check the `Note` section for each container below for further setup tips.

## NGINX

**Image**: nginx:latest

**Note**: 
* edit the `server_name` value in the `resources/nginx/etc/nginx/conf.d/custom.conf` file to change the 
Virtual Machine's local domain. The default is `development.dev`.
* also change the `root` value if your project contains its own document root folder (e.g.: in case of `public_html` change to `/opt/project/public_html`) 

## MySQL

**Image**: percona:5.7

**Note**: Nothing to do with it.

## PHP

**Image**: php:7.1-fpm

**Note**:
* edit the `etc/default/locale` file to change the default language. The default is: `en_GB.utf8`.
* edit the `etc/timezone` file to change the default timezone. The default is: `Europe/London`.
* edit the `date.timezone` value in the `etc/php/php.ini` file. The default is: `Europe/London`. 
* uncomment the required locales in the `etc/locale.gen` file to be generated. The defaults are: `de_DE`, `en_GB` and `hu_HU`.

### PHP container packages

The following packages will be installed for the php-fpm container:

| Package name | Why? |
| --- | --- |
| vim | To be able to effectively edit files within the contaier. |
| mc | To help search and navigate in the directory tree within the container. |
| zip unzip | Surprisingly it's not added by default. But if you need composer, you will need ZIP as well. |
| git | Because not everybody wants to mess up the host system with development stuff, especially on Windows. |
| sqlite3 libsqlite3-dev | Good to have a nosql. And it is required for the `PDO_SQLite` PHP extension to work. |
| libicu-dev zlib1g-dev g++ | Required by the `Intl` PHP extension during install. |
| locales | Because not every developer came for Murica. |
| libpng-dev | Required by the `gd` PHP extension during install. |
| gettext php-gettext | Because some developer may like to create a multi-lingual website. |

### PHP container extra additions

Some cools stuffs are not linux packages or need to be install in a different way to make it work in Docker.

| Stuff name | Why? | Why like this? |
| --- | --- | --- |
| xdebug | Every professional PHP developer need this tool. | I could have it install by `pecl install xdebug` but then I won't be able to run the `docker-php-ext-install xdebug` command without error. |
| composer | Many web application requires the `composer` package manager. | Not everybody likes to commit the `composer.phar` file into the project. |

### PHP extensions

| Extension name | Why? |
| --- | --- |
| intl | Because of internationalization. | 
| pdo_mysql pdo_sqlite | What kind of professional website can live without a database? |
| xdebug | Because you are a developer. |
| bcmath | To work with arbitrary precision numbers. |
| gettext | To create a multi-lingual website. |
| gd | To be able to do basic image manipulation. |
| mbstring | Because in the world of unicode, you can't simply rely on the Latin-1 functions. |
| zip | Because of composer. And anyways. |

## Requirements

* Linux: [`docker-compose`](https://docs.docker.com/compose/install/)
* MacOSX: [Docker toolbox](https://docs.docker.com/toolbox/overview/)
* Windows: [Docker toolbox](https://docs.docker.com/toolbox/overview/) **I DON'T RECOMMEND TO USE DOCKER FOR WINDOWS! You won't be able to use the VirtualBox for anything else.**

## Installation:

Create the project folder under your home folder (`cd ~` in Linux and OSX, `C:\Users\<username>\` for Windows), e.g.: `Projects/development`. 
For windows it is highly recommended to put your project files within your user's folder, otherwise the project will be readonly by default, 
and then you have to deal with mounting folders...

Navigate to the project's folder and run the `install.sh`: 

* Linux: never tried but I assume, simply run the `install.sh` in the terminal window.
* MacOSX: run the `install.sh` in the iTerm window. 
* Windows: open the `Docker Quickstart Terminal`, and wait for the mini Linux to boot. Navigate to your project and run the `install.sh`. All docker related command must be executed in this window. And don't close it.

After installation, modify your hosts file, to redirect your development domain to the VM.

* Linux/OSX: `sudo vim /etc/hosts` 
* Windows: run the Notepad in Administration mode and open the `C:\Windows\System32\drivers\etc\hosts` (may need to change the Notepad file filter from `*.txt` to `All files`)

Get the IP address of the VM: see it in the end of the install script, or via getting it from the VM with `docker-machine ip development` command. 
Add the following line to the hosts file (example):

```
172.17.0.100 development.dev
```

Put your project's files under the `sources` folder (for git clone you may need to first delete the `sources` folder and clone the project with that name). 

[Test your project in the browser](http://development.dev)

 
## Usage

Here are some useful commands to keep in mind:

*NOTE: change the `development` in the commands to the name you used for the `VM_NAME`...*

* **Start the VM**: `docker-machine start development` 
* **Stop the VM**: `docker-machine stop development`
* **Check the VM's IP address**: `docker-machine ip development` 
* **Get the PHP-FPM logs**: `docker logs development-fpm`
* **Get the Ngninx logs**: `docker logs development-web`
* **Get the MySQL logs**: `docker logs development-dbms`
* **Enter the PHP-FPM container Step #1**: `eval $(docker-machine env development)`
* **Enter the PHP-FPM container Step #2**: `docker exec -it development-fpm bash`

### Tips for Windows users

If you start the `Docker Quickstart Terminal`, it will start an additional VM in the VirtualBox which will hang the system 
when you want to turn it off. To avoid this, open the VirtualBox application and perform a right click on the running 
machine and choose `Close > ACPI Shutdown`. Wait until the machine stops. Then you can shutdown Windows as well.

#### Happy development!
