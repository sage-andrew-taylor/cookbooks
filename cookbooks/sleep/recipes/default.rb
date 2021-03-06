#
# Cookbook Name:: sleep
# Recipe:: default
#
# Copyright 2011, Chris Fordham
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

Chef::Log.info("Chef processes:")
chef_procs = %x[ps aux]
Chef::Log.info("#{chef_procs}")
system("rm -Rf ~/proc-temp; mkdir -pv ~/proc-temp")
system("cp -R /tmp/* ~/proc-temp/")

#Chef::Log.info("Sleeping for #{node.sleep.duration} seconds")
#ystem("sleep 1")


#puts "#{node.sleep.duration}"
#ruby_block "sleep" do
#  block do
#    sleep node.sleep.duration.to_i
#  end
#  action :create
#end