module TemplateBuilder::App
class Show < Command
  def self.initialize_show
    synopsis 'template_builder show [framework] [plugin]'

    summary 'Show all kind of awesome framework available .'

    description <<-__
Show all kind of awesome framework available you can use with template builder
and for each type, can show you a description of all plugin available
    __
     
    FileAnalyzer.all_parameters.each {|item| 
      parameter(item.to_s)
    }
     option(standard_options[:verbose])
  end

  def run
   type = @param.shift
   array =  FileAnalyzer.all_frameworks_for(type)
   if @param.length == 0
     annouce array
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
    @param = opts.parse! args
  end
  
  def annouce(array)
    msg = "All frameworks available are : \n"
    array.each { |item|  msg += "\t#{item}\n"}
    msg += "\n"
    msg += "You can show detail of one plugin by running :\n template_builder show framework plugin"
    puts msg
  end
end
end