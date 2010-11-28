require "singleton"

module TemplateBuilder::App::FileAnalyzer
  
  def self.load_standard_parameters
    FileParameter.instance.parameters
  end
  
  def self.all_parameters
    FileParameter.instance.parameters_names
  end
  
  def self.load_conf_file(file_name)
    YAML.load_file(File.join(TemplateBuilder::PATH,"/conf/"+file_name.to_s+".yml"))
  end
  
  def self.load_framework(name)
    FileFramework.new(name).load_framework
  end
  
  class FileParameter
    include Singleton
    
    attr_reader :parameters
    
    def initialize
      @parameters = {}
      load_conf_file
      analyse_file
    end

    def analyse_file
      @config_file.each{ |k,v| @parameters[k.to_sym] = ["-#{k[0..0].to_s}:", "--#{k}:NAME", "#{v.capitalize} .",
              lambda { |item| puts item; config[k.to_sym] = item }]  }
    end
    
    def load_conf_file
      @config_file = TemplateBuilder::App::FileAnalyzer.load_conf_file "parameter_file"
    end
    
    def parameters_names
      @parameters.each_key.to_a
    end
  end
  
  class FileFramework
    
    def initialize(args)
     @name = args 
    end
    
    def load_framework
      load_conf_file
      
    end
    
    def load_conf_file
      @config_file = TemplateBuilder::App::FileAnalyzer.load_conf_file @name
    end
    
  end

end