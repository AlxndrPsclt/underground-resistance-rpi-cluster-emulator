#!/bin/sh

source .env


if [ -d $CLUSTER_VIRLTUAL_DISK_FOLDER ]; then
	echo "The virtual disk folder specified in .env already exists at: $CLUSTER_VIRLTUAL_DISK_FOLDER"
else
	echo "The folder $CLUSTER_VIRLTUAL_DISK_FOLDER will be created to host the virtual disk file."
	mkdir -p $VOLUMES_PATH
	#TODO: Download the image file
fi

if [ -f $SEED_IMAGE_PATH ]; then
	echo "File $SEED_IMAGE_PATH exists."
else
	echo "File $SEED_IMAGE_PATH does not exist. We will try to download it."
	#TODO: Download the image file
fi


#docker-compose up
