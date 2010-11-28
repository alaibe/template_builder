
module TemplateBuilder::App
class Command

  # :startdoc:

  attr_reader :stdout
  attr_reader :stderr
  attr_reader :config

  def initialize( opts = {} )
    @stdout = opts[:stdout] || $stdout
    @stderr = opts[:stderr] || $stderr
    @config = {}
  end

  def run( args )
    raise NotImplementedError
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
    if self.class.options and not self.class.options.empty?
      opts.separator 'PARAMETERS'
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
    return @standard_options if @standard_options
    @standard_options = TemplateBuilder::App::FileAnalyzer.load_standart_options
    @standard_options[:verbose] = ['-v', '--verbose', 'Enable verbose output.',
            lambda { config[:verbose] = true }]
    @standard_options[:force] = ['-f', '--force', 'Force creating file.',
            lambda { config[:force] = true }]
    @standard_options      
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
