module Bookmarks
  module Config
    def root
      @root ||= File.expand_path("../..", __FILE__)
    end

    def env
      ENV["RACK_ENV"]
    end

    def logger
      @logger ||= Logger.new(logger_file)
      @logger.level ||= Logger::ERROR
      @logger
    end

    def logger_file
      File.join(root, 'log', "#{env}.log")
    end
  end
end
