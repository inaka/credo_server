#!/bin/bash


## INARll ERLANG
cd /tmp
wget http://erlang.org/download/otp_src_18.2.1.tar.gz
tar -xvzf otp_src_18.2.1.tar.gz
cd otp_src_18.2.1
./configure
make
make install

## INSTALL REBAR
# cd /tmp
# git clone git://github.com/rebar/rebar.git
# cd rebar
# ./bootstrap
# mv rebar /usr/local/bin/
chmod +x /usr/local/bin/rebar

## INSTALL REBAR3
cd /tmp
wget https://github.com/erlang/rebar3/releases/download/3.1.1/rebar3
cp rebar3 /usr/local/bin/
chmod +x /usr/local/bin/rebar3


## INSTALL ELIXIR
cd /tmp
git clone https://github.com/elixir-lang/elixir.git
cd elixir
make clean install

## Elixir mix setup
yes | mix local.hex
mix hex.info

rm -rf /tmp/*
