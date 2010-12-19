require "singleton"

module TemplateBuilder::App::FileAnalyzer
  
  def self.load_standard_parameters
    FileParameter.instance.parameters
  end
  
  def self.all_parameters
    FileParameter.instance.parameters_names
  end
  
  def self.load_priority(type_name)
    FileParameter.instance.priority type_name
  end
  
  def self.load_conf_file(file_name)
    YAML.load_file(File.join(TemplateBuilder::PATH,"/conf/"+file_name.to_s+".yml"))
  end
  
  def self.all_frameworks_for(name)
    FileFramework.new(name).all_frameworks
  end
  
  def self.load_framework(opts = {})
    FileFramework.new(opts[:type]).load_framework opts[:name]
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
      @config_file.each{ |k,v| @parameters[k.to_sym] = ["-#{k[0..0].to_s}", "--#{k} FRAMEWORK", "#{v['help'].capitalize} .",
              lambda { |item| @config_param[k.to_sym] = Parameter.new :priority=>0,:name=>item }]  }
    end
    
    def load_conf_file
      @config_file = TemplateBuilder::App::FileAnalyzer.load_conf_file "parameter_file"
    end
    
    def parameters_names
      @parameters.each_key.to_a
    end
    
    def priority(type_name)
      @config_file[type_name.to_s]["priority"]
    end
  end
  
  class FileFramework
    
    def initialize(args)
     @name = args 
     load_conf_file
    end
    
    def all_frameworks
      @config_file.each_key.to_a
    end
    
    def load_conf_file
      @config_file = TemplateBuilder::App::FileAnalyzer.load_conf_file @name
    end
    
    def load_framework(name)
      opts = {:name => name, :gems =>[]}
      @config_file[name].each do |key, value|
        if ["command","action"].include? key
          opts[key.to_sym] = value
        else
          gem = {:name => key}
          value.each {|key,value| gem[key.to_sym] = value}
          opts[:gems] << gem
        end
      end 
      TemplateBuilder::App::Helper.framework_factory opts
    end
    
  end

end