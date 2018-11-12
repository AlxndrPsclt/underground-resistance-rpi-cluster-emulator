#RPI cluster emulator

Using the Simonpi docker image, this project emulates a cluster of RPI3.

#Config

To configure, copy the .env.default to .env and edit this file.

It needs a base Raspbian image to run. You should place yours in the images folder, and adjust the .env file to reflect the image name.
If no image is provided the latest Raspbian will be downloaded and used.

A custom cluster-compose.yml file will be generated. Virtual disks will be created if they don't exist.

#Ansible autoconf

The goal of the project is to create and auto-configure a cluster of RPI3. The ansible folder contains what is necessary to generate an ansible container that can run against the virtual-cluster. You should specify a path to your ansible playbooks and inventory files in the .env file.

To allow for autoconfiguration of the cluster, ssh must be active on the supplied Raspbian image. This is not the case by default. The recommended way is to launch the cluster with the default image, wait for it to boot up then attach with:

```bash
docker attach underground-resistance-001
```

Next step is to activate ssh on the image via the configuration wizard:

```bash
sudo raspi-config
```

Finally, navigate to the virtual_disks folder that corresponds to the current run; and copy the .img file to the images folder. This image will have ssh enabled and any container instanciated with it will be ssh accessible. Use this image instead of default by adjusting the .env file.




#Run

All you have to do is run:
```bash
./launch-cluster.sh
```
