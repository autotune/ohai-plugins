#ENV['GEM_HOME'] = nil
#ENV['GEM_PATH'] = nil
#ENV['GEM_CACHE'] = nil

require 'serverspec'
require 'pathname'
require 'busser'
require 'busser/rubygems'

def find_file_by_extension(dir, extension)
  result = nil
  Dir.foreach(dir) do |file|
    result = file if File.extname(file) == extension
  end
  return result
end

# def build_gem(dir, gemspec_file)
#  pwd = Dir.pwd
#  Dir.chdir(dir)
#  gemspec = Gem::Specification.load(gemspec_file)
#  gem = Gem::Builder.new(gemspec).build
#  Dir.chdir(pwd)
#  return gem
# end

# TODO: Use environment variables for directory paths
dir = '/opt/ohai-solo'
gem = find_file_by_extension(dir, '.gem')
# unless gem
#  gemspec = find_file_by_extension(dir, '.gemspec')
#  gem = build_gem(dir, gemspec)
#  gem_name, version = gem.split("-")
# end

# Busser::RubyGems.install_gem(File.join(dir, gem), version)

require 'ohai'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
  end
end

# Setup proper path for sudo environment
path = ENV['PATH'].split(":")
["/sbin", "/usr/sbin", "/usr/local/sbin"].each do |dir|
  if !path.include?(dir)
    path.insert(0, dir)
  end
end
ENV['PATH'] = path.join(":")

PLUGIN_PATH = "/opt/ohai-solo/plugins"
Ohai::Config[:plugin_path] << PLUGIN_PATH
o = Ohai::System.new
o.all_plugins

OHAI = o.data
puts OHAI
