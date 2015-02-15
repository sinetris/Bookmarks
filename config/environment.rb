ENV["RACK_ENV"] ||= 'development'

require 'bundler/setup'
require 'logger'
require 'yaml'
require 'forwardable'
require_relative 'config'

Bundler.require :default, ENV['RACK_ENV']

class App
  class << self
    extend Forwardable
    def_delegators :app, :map, :use, :call
    alias :_new :new
    def new(*args, &block)
      app.run _new(*args, &block)
      app
    end
    def app
      @app ||= Rack::Builder.new
    end
  end

  extend Bookmarks::Config
end

def autoload_dir(dir)
  dir.each do |file|
    without_ext = File.basename(file, '.rb').to_s
    const = without_ext.split("_").map {|word| word.capitalize}.join
    autoload const, file
  end
end

autoload_dir(Dir[File.expand_path('../../app/**/*.rb', __FILE__)])

Dir[File.expand_path('../initializers/*.rb', __FILE__)].each { |f| require f}
