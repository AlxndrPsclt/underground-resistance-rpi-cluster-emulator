#! /usr/bin/env bash

RED='\033[0;31m'
BROWN='\033[0;33m'
GREEN='\033[0;32m'
L_GRAY='\033[0;37m'
NC='\033[0m' # No Color


echo -e "Preparing the launch of the RPI emulator.\n"
echo -e "${L_GRAY}All config comes from the .env file${NC}"
echo "Generating cluster-compose.yml file..."

if [ ! -f .env ]; then
	cp .env.default .env
fi

if [ ! -f cluster-compose.yml ]; then
	touch cluster-compose.yml
else
	echo -e "${BROWN}cluster-compose.yml exists, stopping the stack...${NC}"
	docker-compose -f cluster-compose.yml down
	echo -e ""
fi

docker-compose -f ./generate-cluster-compose/generate-compose.yml up
echo -e "${GREEN}cluster-compose.yml is ready.${NC}\n"

echo -e "Preparing virtual disks..."

source ./.env

if [ -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo "The virtual disk folder specified in .env already exists at: $CLUSTER_VIRTUAL_DISKS_FOLDER"
	read -p "Do you want to delete it and start with a new cluster?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo -e "${RED}Deleting the content of $CLUSTER_VIRTUAL_DISKS_FOLDER.${NC}"
		sudo rm -rf $CLUSTER_VIRTUAL_DISKS_FOLDER
	fi
fi

if [ ! -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo "The folder $CLUSTER_VIRTUAL_DISKS_FOLDER will be created to host the virtual disk file."
	mkdir -p $CLUSTER_VIRTUAL_DISKS_FOLDER

	for i in `seq -w 1 $NUMBER_OF_RPI_NODES`; do
		no=$(printf "%03d" $i)
		NODE_VIRTUAL_DISK_FOLDER=$CLUSTER_VIRTUAL_DISKS_FOLDER/underground-resistance-$no
		mkdir -p $NODE_VIRTUAL_DISK_FOLDER
		echo "Created virtual folder disk for node underground-resistance-$no"

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

		echo "$SEED_IMAGE_PATH will be copied to the virtual disk n°$i."
		cp $SEED_IMAGE_PATH $NODE_VIRTUAL_DISK_FOLDER
	done
fi

echo -e "${GREEN}Virtual disks ready."
echo -e "Everything is ready, launching the virtual cluster.${NC}"

docker-compose -f cluster-compose.yml up
