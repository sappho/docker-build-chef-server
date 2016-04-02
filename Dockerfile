FROM ubuntu:trusty

MAINTAINER Andrew Heald <andrew@heald.uk>

RUN apt-get -qq update && apt-get -qq -y install curl && apt-get clean

ARG download_link=https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.4.1-1_amd64.deb

RUN curl --fail --silent --location --retry 3 $download_link > /opt/chef-server.deb && \
    dpkg -i /opt/chef-server.deb && rm -fv /opt/chef-server.deb

ADD /opt/* /opt/

VOLUME /etc
VOLUME /opt/opscode
VOLUME /var/opt/opscode
VOLUME /var/log/opscode

EXPOSE 443

CMD /opt/start-chef-server.sh
