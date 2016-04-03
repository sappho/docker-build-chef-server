FROM ubuntu:trusty

MAINTAINER Andrew Heald <andrew@heald.uk>

RUN apt-get -qq update && apt-get -qq -y install curl && apt-get clean

ARG download_link=https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.4.1-1_amd64.deb

RUN curl --fail --silent --location --retry 3 $download_link > /opt/chef-server.deb && \
    dpkg -i /opt/chef-server.deb && rm -fv /opt/chef-server.deb

ADD opt /opt/
ADD etc /etc/

RUN groupadd -g 999 -r opscode && groupadd -g 998 -r opscode-pgsql && \
    useradd -d /opt/opscode/embedded -g 999 -l -M -r -s /bin/sh -u 999 opscode && \
    useradd -d /var/opt/opscode/postgresql -g 998 -l -M -r -s /bin/sh -u 998 opscode-pgsql

VOLUME /etc/opscode
VOLUME /etc/opscode-analytics
VOLUME /opt/opscode
VOLUME /var/opt/opscode
VOLUME /var/log/opscode

EXPOSE 443

CMD /opt/start-chef-server.sh
