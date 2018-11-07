#RPI cluster emulator

Using the Simonpi docker image, this project emulates a cluster of RPI3.

To configure, copy the .env.default to .env and edit this file. The main parameter is the NUMBER_OF_RPI_NODES.

It needs a base raspbian image to run. You should place yours in the images folder, and adjust the .env file to reflect the image name.
If no image is provided the latest raspbian will be downloaded and used.

A custom cluster-compose.yml file will be generated. Virtual disks will be created if they don't exist.

All you have to do is run:
```bash
./launch-cluster.sh
```
