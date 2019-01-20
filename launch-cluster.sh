#! /usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
BROWN='\033[0;33m'
GREEN='\033[0;32m'
L_GRAY='\033[0;37m'
L_PURPLE='\033[1;35m'
NC='\033[0m' # No Color


echo -e "${BLUE}Preparing the launch of the RPI emulator.\n"
echo -e "${L_GRAY}All config comes from the .env file"
echo -e "${BROWN}Generating cluster-compose.yml file..."

if [ ! -f .env ]; then
	cp .env.default .env
fi

if [ ! -f cluster-compose.yml ]; then
	touch cluster-compose.yml
else
	echo -e "${RED}cluster-compose.yml exists, cleaning the stack...${NC}"
	sudo docker-compose -f cluster-compose.yml down
	echo -e ""
fi

sudo docker-compose -f ./generate-cluster-compose/generate-compose.yml up
echo -e "${GREEN}cluster-compose.yml is ready.\n${NC}"

echo -e "${BROWN}Preparing virtual disks...${NC}"

source ./.env

if [ -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo -e "${L_GRAY}The virtual disk folder specified in .env already exists at:${NC} $CLUSTER_VIRTUAL_DISKS_FOLDER"
	read -p "Do you want to delete it and start with a new cluster?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "${RED}Deleting the content of $CLUSTER_VIRTUAL_DISKS_FOLDER.${NC}"
		sudo rm -rf $CLUSTER_VIRTUAL_DISKS_FOLDER
	fi
fi

if [ ! -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo -e "${L_GRAY}The folder $CLUSTER_VIRTUAL_DISKS_FOLDER will be created to host the virtual disk file.${NC}"
	mkdir -p $CLUSTER_VIRTUAL_DISKS_FOLDER

	for i in `seq -w 1 $NUMBER_OF_RPI_NODES`; do
		no=$(printf "%03d" $i)
		
		if [ ! -f $SEED_IMAGE_PATH ]; then
			echo -e "${BROWN}File $SEED_IMAGE_PATH does not exist. Downloading the latest raspbian image...${NC}"
			wget -q --show-progress -P $SEED_IMAGES_PATH https://downloads.raspberrypi.org/raspbian_lite_latest
			unzip -d $SEED_IMAGES_PATH $SEED_IMAGES_PATH/raspbian_lite_latest
			NEW_SEED_IMAGE_FILENAME=`zipinfo -1 images/raspbian_lite_latest`
			SEED_IMAGE_PATH="$SEED_IMAGES_PATH/$NEW_SEED_IMAGE_FILENAME"  #Will be created if doesn't exist
			rm $SEED_IMAGES_PATH/raspbian_lite_latest
			echo "${GREEN}Going forward with downloaded raspian image: $NEW_SEED_IMAGE_FILENAME.${NC}"
			sed -i.bak s/$SEED_IMAGE_FILENAME/$NEW_SEED_IMAGE_FILENAME/g .env
		fi

		echo -e "$SEED_IMAGE_PATH will be copied to the virtual disk n°$i.${NC}"
		NODE_VIRTUAL_DISK_FOLDER=$CLUSTER_VIRTUAL_DISKS_FOLDER/underground-resistance-$no
		mkdir -p $NODE_VIRTUAL_DISK_FOLDER
		cp $SEED_IMAGE_PATH $NODE_VIRTUAL_DISK_FOLDER
		echo -e "${GREEN}Created virtual folder disk for node underground-resistance-$no${NC}"
	done
fi

echo -e "${GREEN}Virtual disks ready.${NC}"
echo -e "${BROWN}Everything is ready, starting the virtual cluster.${NC}"

sudo docker-compose -f cluster-compose.yml up -d
ANSIBLE_ID=$(sudo docker ps -aq --filter "name=ansible")

echo -e "${GREEN}Attaching to ansible container:${NC}"
sudo docker attach $ANSIBLE_ID