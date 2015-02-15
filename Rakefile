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

task :environment do
end

require File.expand_path("../config/environment", __FILE__)

seed_loader = Object.new
seed_loader.instance_eval do
  def load_seed
    load "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/seeds.rb"
  end
end

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.root                   = App.root
  config.env                    = ENV["RACK_ENV"] || "development"
  config.db_dir                 = "db"
  config.migrations_paths       = ["db/migrate"]
  config.fixtures_path          = "test/fixtures"
  config.seed_loader            = seed_loader
  config.database_configuration = ActiveRecord::Base.configurations
end

load 'active_record/railties/databases.rake'
