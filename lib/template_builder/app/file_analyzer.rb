require "singleton"

module TemplateBuilder::App::FileAnalyzer
  
  def self.load_standard_parameters
    FileParameter.instance.parameters
  end
  
  def self.all_parameters
    FileParameter.instance.parameters_names
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
      @config_file.each{ |k,v| @parameters[k.to_sym] = ["-#{k[0..0].to_s}", "--#{k} : NAME", "#{v.capitalize} .",
              lambda { |item| config[k.to_sym] = item }]  }
    end
    
    def load_conf_file
      @config_file = YAML.load_file(File.join(TemplateBuilder::PATH,"/conf/option_file.yml"))
    end
    
    def parameters_names
      @parameters.each_key.to_a
    end
  end
  
  

end