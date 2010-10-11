#
# Cookbook Name:: sys
# Recipe:: hostname
#
# Copyright 2010, Chris Fordham
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# RightScript: Set system host name
#
# Author: Chris Fordham <chris.fordham@rightscale.com>
# Copyright (c) 2007-2008 by RightScale Inc., all rights reserved worldwide
#
# Description: Set the system's host name
# Inputs:
# HOST_SHORT_NAME			The short host name (non-canonical) of the server e.g. xhost.com.au
# HOST_FQDN			The FQDN in DNS of the server e.g. starbug.xhost.com.au
# HOST_DOMAIN_NAME			The domain name of the server e.g. xhost.com.au
# HOST_SET_FQDN				Set the FQDN of the server in /etc/hostname (true/false)
# HOST_DOMAIN_SUFFIX_SEARCH	The search domain suffixes to use in /etc/resolv.conf e.g. xhost.com.au dev.host.com.au
# HOST_DOMAIN_LOCALHOST		Bind the domain name to /etc/hosts e.g. domain xhost.com.au (true/false)
#
# Note: this current does currently overwrite /etc/hosts
#

require 'socket'

 def local_ip
   orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

   UDPSocket.open do |s|
     s.connect '64.233.187.99', 1
     s.addr.last
   end
 ensure
   Socket.do_not_reverse_lookup = orig
 end

ruby_block "set_system_hostname" do
  block do
     # Display current hostname values
    Chef::Log.info("Current hostname values:")
    Chef::Log.info("* Hostname: #{`hostname` == '' ? '<none>' : `hostname`}")
    Chef::Log.info("* Network node hostname: #{`uname -n` == '' ? '<none>' : `uname -n`}")
    Chef::Log.info("* Alias names of host: #{`hostname -a` == '' ? '<none>' : `hostname -a`}")
    Chef::Log.info("* Short host name (cut from first dot of hostname): #{`hostname -s` == '' ? '<none>' : `hostname -s`}")
    Chef::Log.info("* Domain of hostname: #{`hostname -d` == '' ? '<none>' : `domainname`}")
    Chef::Log.info("* FQDN of host: #{`hostname -f` == '' ? '<none>' : `hostname -f`}")
    
    # Update /etc/hosts
    #echo "127.0.0.1	$HOST_FQDN $HOST_DOMAIN_NAME $HOST_SHORT_NAME localhost localhost.localdomain" > /etc/hosts

    #
    # Update /etc/resolv.conf
    #
    #echo "search $HOST_DOMAIN_SUFFIX_SEARCH" >> /etc/resolv.conf
    #echo "domain $HOST_DOMAIN_NAME" >> /etc/resolv.conf

    #elif [ "$RS_DISTRO" = 'centos' ]; then

    	#echo 'Setting hostname.'
    	#sed -i "s/HOSTNAME=.*/HOSTNAME=$HOST_FQDN/" /etc/sysconfig/network
    	#hostname "$HOST_FQDN"

    #fi
  end
  action :create
end

# Update /etc/hosts
template "/etc/hosts" do
  source "hosts.erb"
  variables(
    :local_ip => local_ip
end

file "/etc/hostname" do
  owner "root"
  group "root"
  mode "0755"
  content "#{nod[:sys][:hostname]}"
  action :create
end


# Call hostname command
bash "set_hostname" do
  code <<-EOH
    hostname #{node.sys.hostname}
  EOH
end

# Call domainname command
bash "set_hostname" do
  code <<-EOH
    domainname #{node.sys.domain_name}
  EOH
end

# can be /etc/init.d/hostname.sh
service "hostname" do
  case node[:platform]
  when "debian","ubuntu"
    service_name "hostname"
  end
  supports :restart => true, :status => true, :reload => true
  action :restart
end

ruby_block "show_new_hostname" do
  block do
    Chef::Log.info("New hostname values:")
    Chef::Log.info("* Hostname: #{`hostname` == '' ? '<none>' : `hostname`}")
    Chef::Log.info("* Network node hostname: #{`uname -n` == '' ? '<none>' : `uname -n`}")
    Chef::Log.info("* Alias names of host: #{`hostname -a` == '' ? '<none>' : `hostname -a`}")
    Chef::Log.info("* Short host name (cut from first dot of hostname): #{`hostname -s` == '' ? '<none>' : `hostname -s`}")
    Chef::Log.info("* Domain of hostname: #{`hostname -d` == '' ? '<none>' : `domainname`}")
    Chef::Log.info("* FQDN of host: #{`hostname -f` == '' ? '<none>' : `hostname -f`}")
  end
  action :create
end