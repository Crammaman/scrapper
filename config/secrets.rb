require 'yaml'
require 'singleton'
class SecretsConfig
  include Singleton
  # This may or may not be a hilariously bad idea
  def initialize

    secrets = YAML.load File.open('.secrets.yaml')

    secrets.each do |key,value|
      self.class.module_eval { attr_accessor key.to_sym }
      eval "@#{key}='#{value}'"
    end
  end
end
