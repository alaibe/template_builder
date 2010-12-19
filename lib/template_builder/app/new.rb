
module TemplateBuilder::App
class New < Command

  def self.initialize_new
    synopsis 'template_builder new [name] [parameter type parameter type] [options]'

    summary 'create a new template for your rails application.'

    description <<-__
create a new template for your rails application. You can add a lot
of option as the database, the javascript framework etc .. 
    __
    
    FileAnalyzer.all_parameters.each {|item| 
      parameter(standard_parameters[item])
    }  
     option(standard_options[:verbose])
     option(standard_options[:force])
  end

  def run
    raise Error, "File #{name} already exists." if !force and test ?e, name
    file_manager = FileManager.new(
      :file => name,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => verbose?
    )
    announce 
    sorted_param =  @config_param.sort{|a,b| a[1].priority <=> b[1].priority }.map
    sorted_param.each{ |k,v| ask_for k unless v.name }
    
    file_manager.start_file sorted_param
    
    sorted_param.each{ |k,v| run_framework file_manager, :type=>k, :name=>v.name unless v.name == "none"}

    file_manager.end_file name, @command
    
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
    msg = "Created '#{file}'"
    msg << " in directory '#{output_dir}'" if name.to_s != output_dir.to_s
    stdout.puts msg
  end

end  # class Create
end  # module TemplateBuilder::App

# EOF
