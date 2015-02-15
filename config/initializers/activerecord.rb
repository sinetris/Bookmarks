config_file = File.join(App.root, 'config/database.yml')

if File.file?(config_file)
  db_options = YAML.load(File.read(config_file))
  ActiveRecord::Base.configurations[App.env] = db_options[App.env]
else
  App.logger.error "#{config_file} not found."
end

unless ActiveRecord::Base.connected?
  ActiveRecord::Base.logger = App.logger
  ActiveRecord::Base.establish_connection ActiveRecord::Base.configurations[App.env]
end
