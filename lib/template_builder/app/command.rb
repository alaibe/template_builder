
module TemplateBuilder::App
class Command

  # :startdoc:
  attr_reader :stdout
  attr_reader :stderr
  attr_reader :config

  def initialize( opts = {} )
    @stdout = opts[:stdout] || $stdout
    @stderr = opts[:stderr] || $stderr
    
    @config = {:name => nil, :force => nil, :verbose =>nil}
    @config_param = {}
    @command = []
    standard_parameters.each_key{ |key| @config_param[key] = [priority(key)]}
  end

  def run( args )
    raise NotImplementedError
  end
  
  def priority(key)
    FileAnalyzer.load_priority key
  end
  # The project name from the command line.
  #
  def name
    @config[:name]
  end
  
  def force
     @config[:force]
  end
  
  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    @config[:verbose]
  end
  #
  #
  def standard_options
    Command.standard_options
  end
  
  def standard_parameters
    Command.standard_parameters
  end

  #
  #
  def parse( args )
    opts = OptionParser.new

    opts.banner = 'NAME'
    opts.separator "  template_builder v#{::TemplateBuilder.version}"
    opts.separator ''
    if self.class.synopsis
      opts.separator 'SYNOPSIS'
      self.class.synopsis.split("\n").each { |line| opts.separator "  #{line.strip}" }
      opts.separator ''
    end

    if self.class.description
      opts.separator 'DESCRIPTION'
      self.class.description.split("\n").each { |line| opts.separator "  #{line.strip}" }
      opts.separator ''
    end
    if self.class.parameters and not self.class.parameters.empty?
      opts.separator 'PARAMETER'
      self.class.parameters.each { |parameter|
        case parameter
        when Array
          parameter << method(parameter.pop) if parameter.last =~ %r/^__/
          opts.on(*parameter)
        when String
          opts.separator("  #{parameter.strip}")
        else opts.separator('') end
      }
      opts.separator ''
    end
    if self.class.options and not self.class.options.empty?
      opts.separator 'OPTION'
      self.class.options.each { |option|
        case option
        when Array
          option << method(option.pop) if option.last =~ %r/^__/
          opts.on(*option)
        when String
          opts.separator("  #{option.strip}")
        else opts.separator('') end
      }
      opts.separator ''
    end
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      stdout.puts opts
      exit
    }
    opts.on_tail ''
    opts.parse! args
    return opts
  end

  #
  #
  def self.standard_options 
    @standard_options = {:verbose => ['-v', '--verbose', 'Enable verbose output.',
            lambda { config[:verbose] = true }],
                         :force =>  ['-f', '--force', 'Force creating file.',
            lambda { config[:force] = true }] }
  end

  def self.standard_parameters 
    return @standard_parameters if @standard_parameters
    @standard_parameters = FileAnalyzer.load_standard_parameters
    @standard_parameters      
  end
  
  def ask_for(framework_name)
    all_frameworks = FileAnalyzer.all_frameworks_for framework_name
    puts "Choose your "+framework_name.to_s+" framework ? (enter 0 for none)"
    until @config_param[framework_name].length == 2
      all_frameworks.each_with_index{ |value,index| puts "("+(index+1).to_s+") "+value.to_s+"\r\n" }
      answer = STDIN.gets
      @config_param[framework_name] << all_frameworks[answer.to_i-1] if (1..all_frameworks.length).include? answer.to_i
      @config_param[framework_name] << "none" if 0 == answer
    end 
    
  end
  
  def run_framework(fileManager, opts = {})
    framework = FileAnalyzer.load_framework opts
    fileManager.write_framework_introduction opts[:name]
    framework.run fileManager
    special_case_data_mapper if @config_param[:orm] == "date_mapper"
    @command << framework.command
  end
  
  def special_case_data_mapper
    fileManager.write "dm-"+@config_param[:database].to_s+"adapter"
  end
  
  module ClassMethods
    def synopsis( *args )
      @synopsis = args.join("\n") unless args.empty?
      @synopsis
    end

    def description( *args )
      @description = args.join("\n") unless args.empty?
      @description
    end

    def summary( *args )
      @summary = args.join("\n") unless args.empty?
      @summary
    end

    def option( *args, &block )
      args.flatten!
      block = args.pop if block.nil? and Proc === args.last
      if block
        args.each { |val|
          next unless val.instance_of? String
          next unless val =~ %r/^--(\w+)/
          args << "__#$1"
          define_method(args.last.to_sym, &block)
          options << args
          break
        }
      else
        options << (args.length > 1 ? args : args.first )
      end
    end

    def parameter(*args)
      args.flatten!
      block = args.pop if block.nil? and Proc === args.last
      if block
        args.each { |val|
          next unless val.instance_of? String
          next unless val =~ %r/^--(\w+)/
          args << "__#$1"
          define_method(args.last.to_sym, &block)
          parameters << args
          break
        }
      else
        parameters << (args.length > 1 ? args : args.first )
      end
    end
    
    def parameters
      @parameters ||= []
    end
    
    def options
      @options ||= []
    end
  end

  def self.inherited( other )
    other.extend ClassMethods
  end

end  # class TemplateBuilder::App::Command
end
# EOF
