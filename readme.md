# Challenges of Running Chef Server in a Docker Container

[Chef Server](https://www.chef.io/chef/) is a collection of a number of services that all normally run as background daemons - somewhat different to the normal Docker thing of interconnected single-app containers. This image is built on the standard Ubuntu Trusty image but I'm looking into the possibility that it should be based on something like the [Phusion Base Image](http://phusion.github.io/baseimage-docker/) - watch this space.

All the processes run as background daemons, and tailing their logs in the foreground keeps the container running and makes log access easy. However, stopping the container with `docker stop`, or when the Docker daemon stops, will cause the Chef Server daemons inside the container to simply be killed. My tests so far suggest that there's no problem with doing this, but this is far from a certainty - beware!

Because there will be no `cron` process in the container I have added `/etc/cron.hourly/opc_logrotate` to the image. It's a copy of the script installed by the Chef Server installation process.

# This Docker Image

This Chef Server image build is a mix of observation, experimentation and snippets from a few other Dockerfiles on [Docker Hub](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=chef-server&starCount=0).

Tags correspond in name to the version of the [Chef Server](https://www.chef.io/chef/) they're built from.

The source code for this image is on GitHub at [sappho/docker-build-chef-server](https://github.com/sappho/docker-build-chef-server). It is distributed under the [MIT license](https://opensource.org/licenses/MIT). Contributions are welcome - please fork and submit pull requests.

[![Build Status](https://travis-ci.org/sappho/docker-build-chef-server.svg?branch=master)](https://travis-ci.org/sappho/docker-build-chef-server)

# Building a Data Volume Container for Persistence

Create a data volue container like this:

    docker run -ti --name chef-data sappho/chef-server date -R

# Running a Chef Server Container

Run a server with a command like this:

    docker run -ti --name chef -h chef.example.com --privileged --volumes-from chef-data -p 443:443 \
        -d --restart always sappho/chef-server

This will cause one of two initialisation processes to run, depending on context:

* If this is a first run against an empty, newly created, data volume container:
    * Chef Server is bootstrapped to a full build.
    * The embedded nginx web server is provisioned with a private key and a corresponding self-signed certificate.
* If this is a new server container using an existing data container then the already bootstrapped Chef Server is simply started again.

Chef Server runs as a set of background daemon processes so the logs are continuously tailed to the console in the foreground to keep this container running. You can therefore monitor the logs with:

    docker logs -f chef

Watch the logs carefully at startup, in particular when building a new server, when you should see no errors and the logs come to a rest looking something like this:

    2016-04-05_22:42:44.15332 [info] Application oc_chef_wm started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15353 [info] Application oc_erchef started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15361 [info] Application eper started on node 'erchef@127.0.0.1'
    2016-04-05_22:42:44.15373 [info] Application efast_xs started on node 'erchef@127.0.0.1'

You can destroy the Chef Server container and rebuild it at any time, but take care of your data volume container.

# Maintenance and Management

To run server maintenance and management tasks with [chef-server-ctl](https://docs.chef.io/ctl_chef_server.html) use a command like this:

    docker exec -ti chef chef-server-ctl status

You can run any of the available `chef-server-ctl` command variants.

# Using a Properly Generated SSL Private Key and Certificate

You should generate a permanent private key and corresponding certficate at your certificate authority of choice. Get [nginx format files](https://www.nginx.com/resources/admin-guide/nginx-ssl-termination/).
