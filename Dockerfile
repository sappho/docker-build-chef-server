FROM ubuntu:trusty

MAINTAINER Andrew Heald <andrew@heald.uk>

RUN apt-get -qq update && apt-get -qq -y install curl && apt-get clean

ARG download_link=https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.4.1-1_amd64.deb

RUN curl --fail --silent --location --retry 3 $download_link > /opt/chef-server.deb && \
    dpkg -i /opt/chef-server.deb && rm -fv /opt/chef-server.deb

RUN groupadd -g 999 -r opscode && groupadd -g 998 -r opscode-pgsql && \
    useradd -d /opt/opscode/embedded -g 999 -l -M -r -s /bin/sh -u 999 opscode && \
    useradd -d /var/opt/opscode/postgresql -g 998 -l -M -r -s /bin/sh -u 998 opscode-pgsql

VOLUME /etc/opscode
VOLUME /etc/opscode-analytics
VOLUME /opt/opscode
VOLUME /var/opt/opscode
VOLUME /var/log/opscode

EXPOSE 443

# start script needs to run as PID 1 so array form needed ...
CMD ["start-chef-server"]

# Added to the image to trace back to the Debian package used to build a server
ENV DOWNLOAD_LINK $download_link

# Override this email address in a private image or when running a server container
ENV NOTIFICATION_EMAIL nobody@example.com

ADD etc /etc/
ADD bin /usr/local/bin/
RUN ln -s /etc/cron.hourly/opc_logrotate /usr/local/bin/opc_logrotate
