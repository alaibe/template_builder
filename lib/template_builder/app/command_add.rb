module TemplateBuilder::App
class Add < Command
  def self.initialize_add
    synopsis 'template_builder add [framework] [plugin]'

    summary 'Add new available framework or plugin at your template_builder .'

    description <<-__
Add new framework (plugin) at your template_builder gem. You can add a new framework
type and new plugin for this framework.
    __
     
     option(standard_options[:force])
     option(standard_options[:verbose])
  end

  def run
   case @param.length
   when 1
     create_framework @param.shift
   when 2
     create_plugin @param.shift, @param.shift
   else
     Raise Exception, "Bad number of argument, see -h for more information"
   end
  end

  def parse( args )
    opts = super args
    config[:name] = args.empty? ? nil : args.join('_')
    if name.nil?
      stdout.puts opts
      exit 1
    end
    @param =  args
  end
  
  def create_framework(name)
    priority = ask_for_priority
    ConfWriter.write_new_framework name, priority
  end
  
  def create_plugin(framework_name,plugin_name)
    raise Exception, "Framework #{name} doesn't exists." unless test ?e, TemplateBuilder::PATH+"/conf/"+framework_name+".yml"
    write = "\n#{plugin_name} :\n"
    answer = "Would you add a gem at your plugin? (y/yes)"
    puts answer
    while ["y\n","yes\n"].include? STDIN.gets
      write += build_new_gem 
      puts answer
    end
    puts "plugin command  ="
    write += "\tcommand :"+STDIN.gets
    puts "plugin action  ="
    write += "\taction :["+STDIN.gets+"]"
    ConfWriter.write_new_plugin framework_name, write
  end
  
  def build_new_gem
     puts "gem name = "    
     msg = "\t"+STDIN.gets
     puts "gem version = "
     msg += "\t\tversion : "+STDIN.gets
     puts "gem source = "
     msg += "\t\tsource : "+STDIN.gets
     puts "gem action = "
     msg += "\t\taction : "+STDIN.gets
     puts "gem command = "
     msg += "\t\tcommand : "+STDIN.gets
     msg
  end

  def ask_for_priority
    puts "Choose the priority of your framework ? (1 <=> hight et 5 <=> less)"
    answer = STDIN.gets until (1..5).include? answer.to_i
    answer
  end
end
end