module TemplateBuilder::App
class Show < Command
  def self.initialize_show
    synopsis 'template_builder show [parameter]'

    summary 'Show all kind of awesome framework available .'

    description <<-__
Show all kind of awesome framework available you can use with template builder
and for each type, can show you a description of all plugin available
    __
     
    FileAnalyzer.all_parameters.each {|item| 
      parameter(item.to_s)
    }
     option(standard_options[:verbose])
     option(standard_options[:force])
  end

  def run
   # raise Error, "File #{name} doesn't exists." if !force and !test ?e, name
   # file_manager = FileManager.new(
   #   :file => name,
   #   :stdout => stdout,
   #   :stderr => stderr,
   #   :verbose => verbose?
   # )
   # announce 
   # sorted_param =  @config_param.sort{|a,b| a[1].priority <=> b[1].priority }.map
   # sorted_param.each{ |k,v| ask_for k unless v.name }
   # 
   # file_manager.start_file sorted_param
   # 
   # sorted_param.each{ |k,v| run_framework file_manager, :type=>k, :name=>v.name unless v.name == "none"}
#
#    file_manager.end_file name, @command
    
  end

  def parse( args )
    opts = super args
    config[:name] = args.empty? ? nil : args.join('_')
    if name.nil?
      stdout.puts opts
      exit 1
    end
  end

  def announce
    complete_name = name.split("/")
    file = complete_name.last
    output_dir = complete_name[0..complete_name.length-2]
    msg = "Editing '#{file}'"
    msg << " in directory '#{output_dir}'" if name.to_s != output_dir.to_s
    stdout.puts msg
  end
end
end