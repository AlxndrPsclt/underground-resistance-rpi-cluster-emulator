FROM python:3.6-stretch

WORKDIR /usr/src/app

RUN mkdir /usr/src/init
COPY requirements.txt /usr/src/init/

RUN pip install --no-cache-dir -r /usr/src/init/requirements.txt
