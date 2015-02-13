#!/bin/sh

# This script builds a docker image with centOS6 + Mark Logic 7 + My SQL 5.6

##############################
# build-source-dir
##############################
# Since Mark Logic rpm requires registration to download, this script assumes that you have already downloaed file:
# MarkLogic-7.0-4.3.x86_64.rpm and saved it to the build source directory path that is passed in are to this script
# docker-commands.sh build-source-dir
buildSourceDir=$1

echo "Using ${buildSourceDir:=$HOME/build-source}"

if [ -d "$buildSourceDir" ]
then
    echo "build-source-dir found $buildSourceDir"
else
    echo "This scripts expects a build-source-dir"
    echo "Cound not find one at: $buildSourceDir"
    exit 1
fi

#TODO match a filename pattern /^MarkLogic-7. for the rpm rather than exact match. 
if [ -e "$buildSourceDir/MarkLogic-7.0-4.3.x86_64.rpm" ]
then
    echo "found $buildSourceDir/MarkLogic-7.0-4.3.x86_64.rpm"
else
    echo "Cound not find Mark Logic rpm at: $buildSourceDir/MarkLogic-7.0-4.3.x86_64.rpm"
    exit 1
fi

# if you don't have the mysql rpm, then get it
# wget http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
if [  ! -e "$buildSourceDir/mysql-community-release-el6-5.noarch.rpm" ]
then
    wget http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm -P "$buildSourceDir"
fi

# Argh, Docker will not resolve anything outside of the docker execution content; so no /home/user/build-source
# I'll copy the build sources and then delete when done
mkdir ./tmp
cp "$buildSourceDir"/* ./tmp

# Builder docker image
sudo docker build --rm=true -t "mightycontent/centos6-ml-mysql" .

# Clean-up copy of build-source
rm -r ./tmp

# Run docker image - export port 8000, 8001, 8002 for ML 2022 for ssh (pwd 123456)
#docker run -p 8000:8000 -p 8001:8001 -p 8002:8002 -p 2022:2022 mightycontent/centos6-ml-mysql
