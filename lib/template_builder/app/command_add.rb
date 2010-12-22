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
    ConfWriter.write_new_plugin framework_name, plugin_name
  end

  def ask_for_priority
    puts "Choose the priority of your framework ? (1 <=> hight et 5 <=> less)"
    answer = STDIN.gets until (1..5).include? answer.to_i
    answer
  end
end
end