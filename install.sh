#!/bin/bash
dir="$(dirname "$0")"
cd $dir

VM_NAME=development

docker-machine create -d virtualbox --virtualbox-host-dns-resolver --virtualbox-cpu-count=2 --virtualbox-memory=2048 --virtualbox-hostonly-cidr="172.18.0.1/16" $VM_NAME
eval $(docker-machine env $VM_NAME)

docker-compose up -d --force-recreate

if [ $? -ne 0 ]; then
    echo "Couldn't start containers!"
    exit 1
fi

if [[ -f "./sources/composer.json" ]]; then
    docker exec -it $VM_NAME-fpm composer install
fi

# Networking and mount
docker-machine ssh $VM_NAME 'echo "sudo umount $(pwd) || true" | sudo tee /var/lib/boot2docker/bootlocal.sh' &> /dev/null
docker-machine ssh $VM_NAME 'echo "sudo /usr/local/etc/init.d/nfs-client start" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null
docker-machine ssh $VM_NAME 'echo "sudo mount -t nfs -o noacl,async 172.18.0.1:/Users $(pwd)" | sudo tee -a /var/lib/boot2docker/bootlocal.sh' &> /dev/null

VM_IP=$(docker-machine ip $VM_NAME)
echo 'Put into /etc/hosts:'
echo ''
echo "    $VM_IP $VM_NAME.dev"
