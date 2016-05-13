FROM ubuntu:14.04

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN apt-get install --fix-missing -y build-essential libncurses5-dev openssl libssl-dev wget git postgresql-client

COPY build/install_erlang.sh .
RUN ./install_erlang.sh

RUN mkdir /myapp
WORKDIR /myapp
COPY . /myapp
COPY ssh/* /root/.ssh/

RUN mix deps.get
RUN mix
