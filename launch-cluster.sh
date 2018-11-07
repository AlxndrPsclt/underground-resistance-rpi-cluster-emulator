#! /usr/bin/env bash

echo "Preparing the launch of the RPI emulator."
echo "All config comes from the .env file"
echo "Generating cluster-compose.yml file..."
if [ ! -f cluster-compose.yml ]; then
	touch cluster-compose.yml
fi
docker-compose -f ./generate-cluster-compose/generate-compose.yml up
echo "cluster-compose.yml is ready."
echo ""

echo "Preparing virtual disks..."


if [ ! -f .env ]; then
	cp .env.default .env
fi
source ./.env

if [ -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo "The virtual disk folder specified in .env already exists at: $CLUSTER_VIRTUAL_DISKS_FOLDER"
	read -p "Do you want to delete it and start with a new cluster?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "Deleting the content of $CLUSTER_VIRTUAL_DISKS_FOLDER."
		rm -rf $CLUSTER_VIRTUAL_DISKS_FOLDER
	fi
fi

if [ ! -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo "The folder $CLUSTER_VIRTUAL_DISKS_FOLDER will be created to host the virtual disk file."
	mkdir -p $CLUSTER_VIRTUAL_DISKS_FOLDER

	for i in `seq -w 001 $NUMBER_OF_RPI_NODES`; do
		NODE_VIRTUAL_DISK_FOLDER=$CLUSTER_VIRTUAL_DISKS_FOLDER/underground-resistance-$i
		mkdir -p $NODE_VIRTUAL_DISK_FOLDER
		echo "Created virtual folder disk for node underground-resistance-$i"

		if [ ! -f $SEED_IMAGE_PATH ]; then
			echo "File $SEED_IMAGE_PATH does not exist. We will try to download the latest raspbian image."
			wget -P $SEED_IMAGES_PATH https://downloads.raspberrypi.org/raspbian_lite_latest
			unzip -d $SEED_IMAGES_PATH $SEED_IMAGES_PATH/raspbian_lite_latest
			SEED_IMAGE_FILENAME=`zipinfo -1 images/raspbian_lite_latest`
			SEED_IMAGE_PATH="$SEED_IMAGES_PATH/$SEED_IMAGE_FILENAME"  #Will be created if doesn't exist
			rm $SEED_IMAGES_PATH/raspbian_lite_latest
			echo "Going forward with downloaded raspian image: $SEED_IMAGE_PATH"
			echo "You might need to change your .env file to use this image next time instead of a new download"
		fi

		echo "$SEED_IMAGE_PATH will be copied to the virtual disk $i."
		cp $SEED_IMAGE_PATH $NODE_VIRTUAL_DISK_FOLDER
	done
fi

echo "Virtual disks ready."
echo "Everything is ready, launching the virtual cluster."

docker-compose -f cluster-compose.yml up
