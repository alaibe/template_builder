require 'yaml'
require File.join(File.dirname(__FILE__),"/framework.rb")
require File.join(File.dirname(__FILE__),"/gem.rb")

class FrameworkBuilder

  def self.build_all_frameworks(type)
    config_file = build_yaml_file
    result = Array.new
    config_file[type.to_s].each_key do |item|
      gems = Array.new
      if config_file[type.to_s][item]
        config_file[type.to_s][item].each_key do |gem|
          array =  config_file[type.to_s][item][gem]
          gems << Gem.new(gem, array["version"], array["source"])
        end
      end
      result << Framework.new(item, gems)
    end
    result
  end

  def self.build_yaml_file
    YAML.load_file(File.join(File.dirname(__FILE__),"/../../gem.yml"))
  end
end