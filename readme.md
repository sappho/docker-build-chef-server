[![Travis](https://img.shields.io/travis/sappho/docker-build-chef-server.svg?style=flat-square)](https://travis-ci.org/sappho/docker-build-chef-server)[![GitHub issues](https://img.shields.io/github/issues/sappho/docker-build-chef-server.svg?style=flat-square)](https://github.com/sappho/docker-build-chef-server/issues)[![GitHub repository](https://img.shields.io/badge/GitHub-master-blue.svg?style=flat-square)](https://github.com/sappho/docker-build-chef-server)[![GitHub forks](https://img.shields.io/github/forks/sappho/docker-build-chef-server.svg?style=flat-square)](https://github.com/sappho/docker-build-chef-server/network)[![GitHub stars](https://img.shields.io/github/stars/sappho/docker-build-chef-server.svg?style=flat-square)](https://github.com/sappho/docker-build-chef-server/stargazers)[![Docker stars](https://img.shields.io/docker/stars/sappho/chef-server.svg?style=flat-square)](https://hub.docker.com/r/sappho/chef-server/)[![Docker pulls](https://img.shields.io/docker/pulls/sappho/chef-server.svg?style=flat-square)](https://hub.docker.com/r/sappho/chef-server/)[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/sappho/docker-build-chef-server/master/LICENSE)

# Challenges

[Chef Server](https://www.chef.io/chef/) is a collection of a number of services that all normally run as background daemons - somewhat different to the normal Docker thing of interconnected single-app containers. This image is built on the standard Ubuntu Trusty image but I'm looking into the possibility that it should be based on something like the [Phusion Base Image](http://phusion.github.io/baseimage-docker/) - watch this space.

All the processes run as background daemons, and tailing their logs in the foreground keeps the container running and makes log access easy. However, stopping the container with `docker stop`, or when the Docker daemon stops, will cause the Chef Server daemons inside the container to simply be killed. My tests so far suggest that there's no problem with doing this, but this is far from a certainty - beware!

Because there will be no `cron` process in the container I have added `/etc/cron.hourly/opc_logrotate` to the image. It's a copy of the script installed by the Chef Server installation process.

# This Docker Image

This Chef Server image build is a mix of observation, experimentation and snippets from a few other Dockerfiles on [Docker Hub](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=chef-server&starCount=0).

Tags correspond in name to the version of the [Chef Server](https://www.chef.io/chef/) they're built from.

The source code for this image is on GitHub at [sappho/docker-build-chef-server](https://github.com/sappho/docker-build-chef-server). It is distributed under the [MIT license](https://opensource.org/licenses/MIT). Contributions are welcome - please fork and submit pull requests.

# SSL

To use Chef Server in a production environment, and really any environment, you should use a properly generated private key and SSL certificate to secure access to the exposed HTTPS port. While this Docker image can be run as is, you should create and build your own image which adds your private key and SSL certificate. You can fork [a sample GitHub repository](https://github.com/sappho/docker-build-chef-server-ssl) to help with this. Put your private key and certificate in `ssl/chef-server.key` and `ssl/chef-server.crt`. Make sure that the certificate is [compatible with nginx](https://www.nginx.com/resources/admin-guide/nginx-ssl-termination/). You should also add your own email address in the `Dockerfile`.

Build your private Docker image and use it instead of this image. Rebuid your private image when you need to update your private key and certificate, and then destroy and re-run your server container to redeploy.

# Data Persistence

Create a data volume container like this:

    docker run -ti --name chef-data sappho/chef-server date -R

You can externalise the data volumes for this image in other ways. If you do then ensure that your create all of the required volumes:

* `/etc/opscode`
* `/etc/opscode-analytics`
* `/opt/opscode`
* `/var/opt/opscode`
* `/var/log/opscode`

# Running a Chef Server Container

When using a data volume container, run Chef Server with a command like this:

    docker run -ti --name chef --hostname chef.example.com --privileged \
        --volumes-from chef-data -p 443:443 \
        -d --restart always sappho/chef-server

This will cause one of two initialisation processes to run, depending on context:

* If this is a first run against an empty, newly created, data volume container:
    * Chef Server is bootstrapped to a full build.
    * The embedded nginx web server is provisioned with a private key and a corresponding self-signed certificate.
* If this is a new server container using an existing data container then the already bootstrapped Chef Server is simply started again.

The `--hostname` switch value is important. It should precisely correspond to the common name in your SSL certificate. If this isn't so then your Chef Server will likely appear to run correctly but will present odd behaviour when creating users and organisations or when accessing the API.

Chef Server runs as a set of background daemon processes so the logs are continuously tailed to the console in the foreground to keep this container running. You can therefore monitor the logs with:

    docker logs -f chef

Watch the logs carefully at startup, in particular when building a new server, when you should see no errors and the logs come to a rest looking something like this:

    2016-04-05_22:42:44.15332 [info] Application oc_chef_wm started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15353 [info] Application oc_erchef started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15361 [info] Application eper started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15373 [info] Application efast_xs started on node 'erchef@127.0.0.1'

You can destroy the Chef Server container and rebuild it at any time, but take care of your data volume container, or other data storage.

# Maintenance and Management

To run server maintenance and management tasks with [chef-server-ctl](https://docs.chef.io/ctl_chef_server.html) use a command like this:

    docker exec -ti chef chef-server-ctl status

You can run any of the available `chef-server-ctl` command variants.

# Reconfiguration

This image injects configuration into `/etc/opscode/chef-server.rb`. If you need to change the configuration in this file then run a command like this:

    docker exec -ti chef vi /etc/opscode/chef-server.rb

Then follow up with:

    docker exec -ti chef chef-server-ctl reconfigure

# Log Rotation

To rotate the logs run:

    docker exec -ti chef opc_logrotate
