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

	if [ ! $(which minikube) == "" ]
	then
		echo -e "${GREEN}Minikube found...${NC}";
	else
		curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-${SYSTEM_TYPE}-amd64"
		sudo install "minikube-${SYSTEM_TYPE}-amd64" /usr/local/bin/minikube
	fi
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
	minikube start --driver=docker #--extra-config=apiserver.service-node-port-range=3000-35000
	minikube addons enable ingress
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

eval $(minikube docker-env)

echo -e "${GREEN}Building Containers... this may take a while...${NC}";
echo -e "${MAGENTA}Mysql...${NC}";
docker build -t phippy-mysql srcs/MySQL >& /dev/null
echo -e "${MAGENTA}Nginx...${NC}";
docker build -t phippy-nginx srcs/Nginx >& /dev/null
echo -e "${MAGENTA}Wordpress...${NC}";
docker build -t phippy-wordpress srcs/WordPress >& /dev/null
echo -e "${MAGENTA}Influxdb...${NC}";
docker build -t phippy-influxdb srcs/influxDB >& /dev/null
echo -e "${MAGENTA}Ftp...${NC}";
docker build -t phippy-ftps srcs/FTPS >& /dev/null
echo -e "${MAGENTA}Grafana...${NC}";
docker build -t phippy-grafana srcs/Grafana >& /dev/null
echo -e "${MAGENTA}Phpmyadmin...${NC}";
docker build -t phippy-phpmyadmin srcs/Phpmyadmin >& /dev/null

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
rm ./srcs/Nginx/srcs/index.html
rm ./srcs/FTPS/srcs/setup.sh
rm ./srcs/Phpmyadmin/srcs/config.inc.php

#---- start ingress
kubectl wait --namespace=kube-system --for=condition=Ready pods --all --timeout 90s
kubectl apply -f srcs/ingress.yaml
kubectl patch deployment ingress-nginx-controller --patch "$(cat ./srcs/Ingress/controller-patch.yaml)" -n kube-system

#---- start dashboard
echo -e "${NC}";
echo -e "${GREEN}Starting Dashboard...${NC}";

minikube dashboard
