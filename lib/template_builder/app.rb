require 'net/http'
require 'uri'

module TemplateBuilder::App
  extend LittlePlugger(:path => 'template_builder/app', :module => TemplateBuilder::App)

  Error = Class.new(StandardError)

  # Create a new instance of Main, and run the +template_builder+ application given
  # the command line _args_.
  #
  def self.run( args = nil )
    args ||= ARGV.dup.map! { |v| v.dup }
    ::TemplateBuilder::App::Main.new.run args
  end

  class Main
    attr_reader :stdout
    attr_reader :stderr

    # Create a new Main application instance. Options can be passed to
    # configuret he stdout and stderr IO streams (very useful for testing).
    #
    def initialize( opts = {} )
      opts[:stdout] ||= $stdout
      opts[:stderr] ||= $stderr

      @opts = opts
      @stdout = opts[:stdout]
      @stderr = opts[:stderr]
    end

    # Parse the desired user command and run that command object.
    #
    def run( args )
      commands = []
      @plugins = ::TemplateBuilder::App.plugins
      @plugins.each { |k,v| commands << k.to_s if v < ::TemplateBuilder::App::Command }
      
      cmd_str = args.shift
      cmd = case cmd_str
        when *commands
          key = cmd_str.to_sym
          @plugins[key].new @opts
        when nil, '-h', '--help'
          help
        when '-v', '--version'
          stdout.puts "TemplateBuilder v#{::TemplateBuilder.version}"
        else
          raise Error, "Unknown command #{cmd_str.inspect}"
        end
      if cmd
        cmd.parse args
        cmd.run
      end

    rescue TemplateBuilder::App::Error => err
      stderr.puts "ERROR:  While executing template builder ..."
      stderr.puts "    #{err.message}"
      exit 1
    rescue StandardError => err
      stderr.puts "ERROR:  While executing template builder ... (#{err.class})"
      stderr.puts "    #{err.to_s}"
      exit 1
    end

    # Show the toplevel Mr Bones help message.
    #
    def help
      msg = <<-MSG
NAME
  Template_builder v#{::TemplateBuilder.version}

DESCRIPTION
  Template-builder is a handy tool that builds a template for your new Ruby
  on Rails projects. The template contains all you need to build the RoR 
  project that you want.

  Usage:
    template_builder -h/--help
    template_builder -v/--version
    bones command [options] [arguments]

  Examples:
    template_builder new new_template
    template_builder edit old_template

  Commands:
      MSG

     fmt = lambda { |cmd|
             if @plugins[cmd] < ::TemplateBuilder::App::Command
               msg << "    template_builder %-15s %s\n" % [cmd, @plugins[cmd].summary]
             end
           }

     ary = [:new, :edit, :info, :info]
     ary.each(&fmt)
     (@plugins.keys - ary).each(&fmt)

      msg.concat <<-MSG

  Further Help:
    Each command has a '--help' option that will provide detailed
    information for that command.

    http://github.com/alaibe/template_builder

      MSG

    stdout.puts msg
    end

  end  # class Main
end  # module Bones::App

# EOF
