#!/bin/sh

# This script builds a docker image with centOS6 + Mark Logic 7 + My SQL 5.6

##############################
# build-source-dir
##############################
# Since Mark Logic rpm requires registration to download, this script assumes that you have already downloaed file:
# MarkLogic-7.0-4.3.x86_64.rpm and saved it to a directory named build-source-dir
buildSourceDir=$1

echo "Using ${buildSourceDir:=build-source}"

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

# Download Dockerfile - you might need to update the url
#curl -k -L -O https://gist.githubusercontent.com/rlouapre/39f3cf793f27895ae8d2/raw/60679c9472bc50c0e72e920eb80dfca066d99463/Dockerfilelocal

# Download supervisord.conf - you might need to update the url
#curl -k -L -O https://gist.githubusercontent.com/rlouapre/39f3cf793f27895ae8d2/raw/cbfbe33c5c5bf23734852560640ffa68cbebeb50/supervisord.conf

# Download locally MarkLogic-7.0-4.x86_64.rpm
# ...

# Builder docker image
#sudo docker build --rm=true -t "mightycontent/centos6-ml-mysql" .

# Run docker image - export port 8000, 8001, 8002 for ML 2022 for ssh (pwd 123456)
#docket run -p 8000:8000 -p 8001:8001 -p 8002:8002 -p 2022:2022 mightycontent/centos6-ml-mysql
