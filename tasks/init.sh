#!/bin/bash

set -x

pe_master_url="https://${PT_pe_master}:${PT_pe_masterport}/packages/current/install.bash"

echo "Stopping current puppet agent..."
/opt/puppetlabs/puppet/bin/puppet resource service puppet ensure=stopped

if [[ -f /etc/yum.repos.d/pc_repo.repo ]]; then
    rm -f /etc/yum.repos.d/pc_repo.repo
fi

if [[ -d /etc/puppetlabs ]]; then
    echo "Removing /etc/puppetlabs..."
    rm -rf /etc/puppetlabs
fi

if [[ -d /opt/puppetlabs ]]; then
    echo "Removing /opt/puppetlabs..."
    rm -rf /opt/puppetlabs
fi

if [[ $(yum list installed | grep puppet-agent) ]]; then
    echo "Erasing puppet agent package..."
    /bin/yum erase -y puppet
fi

echo "Installing new puppet agent from ${pe_master_url}..."
/bin/curl -k "${pe_master_url}" | sudo bash -s agent:masterport="${PT_pe_masterport}"

fr_cmd="/opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/bin/puppet agent --no-daemonize"
fr_pid=$(ps -ef | grep "${fr_cmd}" | grep -v grep | awk '{print $2}')

if [ ! -z $fr_pid ]; then
    echo "Short-circuit first triggered puppet run..."
    kill -9 "${fr_pid}"
fi

echo "Run puppet for the first time..."
if [ $(/opt/puppetlabs/puppet/bin/puppet agent -t > /dev/null 2>&1; echo $?) == 1 ]; then
    echo "Puppet Agent is installed! Please sign the certificate request for this node."
fi

