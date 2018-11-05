#! /usr/bin/env bash

source ./.env


if [ -d $CLUSTER_VIRTUAL_DISKS_FOLDER ]; then
	echo "The virtual disk folder specified in .env already exists at: $CLUSTER_VIRTUAL_DISKS_FOLDER"
	#TODO: Give option to delete or proceed
else
	echo "The folder $CLUSTER_VIRTUAL_DISKS_FOLDER will be created to host the virtual disk file."
	mkdir -p $CLUSTER_VIRTUAL_DISKS_FOLDER

	for i in `seq -w 001 $NUMBER_OF_RPI_NODES`;
	do
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



#docker-compose up
