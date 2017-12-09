#!/bin/bash
dir="$(dirname "$0")"
cd $dir

docker-machine create -d virtualbox --virtualbox-host-dns-resolver --virtualbox-cpu-count=2 --virtualbox-memory=2048 --virtualbox-hostonly-cidr="172.17.0.1/16" webhemi
eval $(docker-machine env webhemi)

docker-compose up -d --force-recreate

if [ $? -ne 0 ]; then
    echo "Couldn't start containers!"
    exit 1
fi

if [[ -f "./sources/composer.json" ]]; then
    docker exec -it webhemi-fpm composer install
    echo "... Done"
fi

docker exec -it webhemi-fpm dpkg-reconfigure locales
# choose  1 for install all locales
# choose 131 to set en_GB.UTF-8 as default
locale-gen

docker-machine ssh webhemi 'echo "sudo umount $(pwd) || true" | sudo tee /var/lib/boot2docker/bootlocal.sh' &> /dev/null
docker-machine ssh webhemi 'echo "sudo /usr/local/etc/init.d/nfs-client start" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null
docker-machine ssh webhemi 'echo "sudo mount -t nfs -o noacl,async 172.17.0.1:/Users $(pwd)" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null
       

VM_IP=$(docker-machine ip webhemi)
echo 'Put into /etc/hosts:'
echo ''
echo "    $VM_IP webhemi.dev"
 
