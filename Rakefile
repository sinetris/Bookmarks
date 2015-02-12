require 'bundler'

ENV["RACK_ENV"] ||= 'development'

begin
  Bundler.setup(:default, ENV["RACK_ENV"])
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
