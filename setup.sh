#! /bin/bash

#----------------- set colors -------------------#
ORANGE="\033[0;31m "
RED="\033[0;31m "
GREEN="\n\033[0;92m "
CYAN="\033[0;36m "
MAGENTA="\033[0;95m "
NC="\033[0m" # No Color
SYSTEM_TYPE="linux"

if [ ! "$1" == "rebuild" ]
then
	
	#------------------- docker ---------------------#

	if [ ! $(which docker) == "" ]
	then
		echo -e "${GREEN}Docker found...${NC}";
	else
		echo -e "${RED}You need Docker to run this app.${NC}";
		exit 1;
	fi

	docker ps > /dev/null;
    if [[ $? == 1 ]];
    then
        printf "${RED}Docker doesn't have the right permissions${NC}";
        sudo usermod -aG docker $USER;
        printf "${GREEN}Permissions were applied. Please log out and in again...${NC}";
        exit 1;

    fi
	#--------------- get system type ----------------#

	if [ "$(uname -s)" == "Darwin" ]
	then
		SYSTEM_TYPE="darwin"
	fi

	#----------------- kubernetes -------------------#

	if [ ! $(which kubectl) == "" ]
	then
		echo -e "${GREEN}Kubernetes found...${NC}";
	else
		echo -e "${GREEN}Downloading and installing Kubernetes...${NC}";
		if [ ${SYSTEM_TYPE} == "Darwin" ]
		then
			curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
		else
			curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
		fi
		chmod +x ./kubectl
		sudo mv ./kubectl /usr/local/bin/kubectl
	fi
	kubectl version --client

	#------------------ minikube --------------------#

	echo -e "${GREEN}Installing/Updating Minikube...${NC}";
	sudo mkdir -p /usr/local/bin/
	curl -Lo minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
	sudo install minikube /usr/local/bin/minikube

	sudo minikube delete
	sudo apt install conntrack

	#----------- setup and permissions --------------#

	echo -e "${GREEN}Setting up permissions...${NC}"
	sudo systemctl enable docker.service
	sudo groupadd docker
	sudo usermod -aG docker $USER
	sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && sudo chmod g+rwx "$HOME/.docker" -R
	sudo chown "$USER":"$USER" /home/"$USER"/.minikube -R && sudo chmod g+rwx "$HOME/.minikube" -R
	sudo chown "$USER":"$USER" /tmp -R && sudo chmod g+rwx /tmp -R
	sudo chown "$USER":"$USER" /home/"$USER"/.kube -R && sudo chmod g+rwx "$HOME/.kube" -R

	#--------------- start minikube -----------------#

	echo -e "${GREEN}Starting Minikube...${NC}"
	minikube start --driver=docker --extra-config=apiserver.service-node-port-range=3000-35000
	minikube addons enable ingress
	minikube addons enable dashboard
	minikube addons enable metrics-server

fi

#----------------- apply config -----------------#

MINIKUBE_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"

#-- nginx index
cp ./srcs/Nginx/srcs/index-raw.html ./srcs/Nginx/srcs/index.html
sed -i "s|__MINIKUBE_IP__|${MINIKUBE_IP}|g" ./srcs/Nginx/srcs/index.html

#-- ftps
cp ./srcs/Phpmyadmin/srcs/config-raw.inc.php ./srcs/Phpmyadmin/srcs/config.inc.php
sed -i "s|__MINIKUBE_IP__|${MINIKUBE_IP}|g" ./srcs/Phpmyadmin/srcs/config.inc.php

#-- ftps
cp ./srcs/FTPS/srcs/setup-raw.sh ./srcs/FTPS/srcs/setup.sh
sed -i "s|__MINIKUBE_IP__|${MINIKUBE_IP}|g" ./srcs/FTPS/srcs/setup.sh

#------------------- build containers ---------------------#

minikube -p minikube docker-env
eval $(minikube docker-env)

docker-compose build
#------------------- apply YAMLs ---------------------#

echo -e "${GREEN}Applying YAMLs...${NC}";
echo -e "${MAGENTA}"

kubectl apply -f srcs/config.yaml
kubectl apply -f srcs/volumes.yaml
kubectl apply -f srcs/mysql.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/wordpress.yaml
kubectl apply -f srcs/ftps.yaml
kubectl apply -f srcs/phpmyadmin.yaml
kubectl apply -f srcs/influxdb.yaml
kubectl apply -f srcs/grafana.yaml

#---- remove tmp files
rm -f ./srcs/Nginx/srcs/index.html
rm -f ./srcs/FTPS/srcs/setup.sh
rm -f ./srcs/Phpmyadmin/srcs/config.inc.php
rm -f minikube
rm -f compose

#---- start ingress
kubectl wait --namespace=kube-system --for=condition=Ready pods --all --timeout 90s
kubectl apply -f srcs/ingress.yaml

#---- start dashboard
echo -e "${NC}";
echo -e "${GREEN}Starting Dashboard...${NC}";

minikube dashboard
