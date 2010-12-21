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
   puts @param
   type = @param.shift
   array =  FileAnalyzer.all_frameworks_for(type)
   if @param.length == 0
   else
     plugin = @param.shift
     framework = FileAnalyzer.load_framework :type=>type, :name=>plugin
     puts framework.to_s
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
  
end
end