# References

* https://github.com/chef/chef-server/issues/435
* https://docs.chef.io/install_server.html
* https://hub.docker.com/r/xmik/chef-server-docker/

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

    docker run -ti --name chef --privileged --volumes-from chef-data -p 443:443 \
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
