#!/bin/bash
rm -fv /opt/opscode/embedded/service/oc_id/tmp/pids/server.pid
/opt/opscode/embedded/bin/runsvdir-start &
if [ -f /etc/opscode/chef-server-running.json ]; then
    chef-server-ctl start
else
    chef-server-ctl reconfigure
fi
tail -f /var/log/opscode/*/current
