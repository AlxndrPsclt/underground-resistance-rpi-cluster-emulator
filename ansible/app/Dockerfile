FROM python:3.6-stretch

WORKDIR /usr/src/app

RUN mkdir /usr/src/init
COPY requirements.txt /usr/src/init/
COPY wait-for-it.sh /usr/src/init/

RUN pip install --no-cache-dir -r /usr/src/init/requirements.txt

RUN apt-get update && apt-get install -y \
	sshpass \
	&& rm -rf /var/lib/apt/lists/*
