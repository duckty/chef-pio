#
# Cookbook Name:: pio
# Recipe:: pio_git_install
#
# Copyright 2016 ActionML LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

include_recipe 'git'
include_recipe 'pio::base'

pio = node['pio'][node['pio']['bundle']]
piodir = File.join(node['pio']['libdir'], 'pio')

directory piodir do
  owner node['pio']['aml']['user']
  group node['pio']['aml']['user']
end

# Clone pio repository
git piodir do
  repository pio['giturl']
  revision pio['gitrev']

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  action(pio['gitupdate'] ? :sync : :checkout)
end

link "#{node['pio']['home_prefix']}/pio" do
  to piodir
end

## Make distribution
#

execute 'make-distribution.sh' do
  cwd piodir
  command 'bash make-distribution.sh'

  user node['pio']['aml']['user']
  group node['pio']['aml']['user']

  not_if "cd #{piodir}; ls sbt/sbt-launch*.jar"
  action :run
end
