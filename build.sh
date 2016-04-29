#!/bin/bash
set -e

version=12.5.0
majorVersion=12.5
download_link=https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_${version}-1_amd64.deb

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker pull phusion/baseimage

echo Building image from $download_link

docker build \
  --build-arg download_link=$download_link \
  -t sappho/chef-server:$version \
  -t sappho/chef-server:$majorVersion \
  -t sappho/chef-server:12 \
  -t sappho/chef-server:latest \
  $directory

docker push sappho/chef-server:$version
docker push sappho/chef-server:$majorVersion
docker push sappho/chef-server:12
docker push sappho/chef-server:latest
