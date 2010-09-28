require "yaml"

module HoptoadTrackerIntegration
  module Pivotal
    class Config
      CONFIG_FILE_NAME = 'pivotal_config.yml'

      # Load config file with symbolized keys
      @@config = YAML.load_file(CONFIG_FILE_NAME).inject({}){|memo, (k,v)| memo.merge({k.to_sym => v})}

      def self.[](attribute)
        @@config[attribute]
      end
    end
  end
end