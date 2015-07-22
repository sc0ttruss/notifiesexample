#
# Cookbook Name:: notifiesexample
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
version = node['notifiesexample']['go_version']
install_path = "#{node['notifiesexample']['go_dir']}"

remote_file "#{Chef::Config[:file_cache_path]}/go#{version}.linux-amd64.tar.gz" do
  source "#{node['notifiesexample']['go_url']}/go#{version}.linux-amd64.tar.gz"
  #checksum node['notifiesexample']['go_checksum']
  mode '0644'
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/go#{version}.linux-amd64.tar.gz") }
  notifies :write, "log[message]", :immediately
  notifies :run, "execute[list contents]", :immediately

end

execute "list contents" do 
  command "ls -al #{Chef::Config[:file_cache_path]}/go#{version}.linux-amd64.tar.gz > /tmp/filelist.txt "
  only_if { File.exist?("#{Chef::Config[:file_cache_path]}/go#{version}.linux-amd64.tar.gz") }
  notifies :run, "ruby_block[retrieve_version]", :immediately
  action :nothing
end

ruby_block 'retrieve_version' do
  block do
    version = File.open("/tmp/filelist.txt").readline.chomp
    node.set['notifiesexmaple']['app-ver'] = version
    puts "Here is the contents of the filelist.txt file:   #{node['notifiesexmaple']['app-ver']}"
  end
  only_if { File.exist?("/tmp/filelist.txt") }
  action :nothing
end

log 'message' do
  message 'Log message printed after notification from remote file'
  level :info
  action :nothing
end
