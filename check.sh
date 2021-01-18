#!/bin/bash

ruby daemon.rb status

if [ $? -ne 0 ];
  then
    ruby daemon.rb start
fi
