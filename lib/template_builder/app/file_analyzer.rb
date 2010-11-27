require "singleton"

module TemplateBuilder::App::FileAnalyzer
  
  def self.load_standart_options
    FileOption.instance.options
  end
  
  def self.all_options
    FileOption.instance.options_names
  end
  
  class FileOption
    include Singleton
    
    attr_reader :options
    
    def initialize
      @options = {}
      load_conf_file
      analyse_file
    end

    def analyse_file
      @config_file.each{ |k,v| @options[k.to_sym] = ["-#{k[0..0].to_s}", "--#{k}", "#{v.capitalize} .",
              lambda { config[k.to_sym] = true }]  }
    end
    
    def load_conf_file
      @config_file = YAML.load_file(File.join(TemplateBuilder::PATH,"/conf/option_file.yml"))
    end
    
    def options_names
      @options.each_key.to_a
    end
  end
  
  

end