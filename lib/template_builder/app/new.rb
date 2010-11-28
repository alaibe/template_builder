
module TemplateBuilder::App
class New < Command

  def self.initialize_new
    synopsis 'template_builder new template_name [options]'

    summary 'create a new template for your rails application.'

    description <<-__
create a new template for your rails application. You can add a lot
of option as the database, the javascript framework etc .. 
    __
    
    TemplateBuilder::App::FileAnalyzer.all_options.each {|item| 
      option(standard_options[item]) }  
     option(standard_options[:verbose])
     option(standard_options[:force])
  end

  def run
    raise Error, "File #{name} already exists." if !force and test ?e, name
    
    fm = FileManager.new(
      :file => name,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => verbose?
    )
    announce 
    
    in_directory(output_dir) {
      self.class.in_output_directory.each {|cmd| self.send cmd}
      fixme
    }
  end

  def parse( args )
    opts = super args
    config[:name] = args.empty? ? nil : args.join('_')
    if name.nil?
      stdout.puts opts
      exit 1
    end
  end

  def copy_files
    fm = FileManager.new(
      :create_file => create_file,
      :file => output_dir,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => verbose?
    )

    fm.copy
    fm.finalize name
  rescue Bones::App::FileManager::Error => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n\t#{err.message}"
    raise Error, msg
  rescue Exception => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n\t#{err.inspect}"
    raise Error, msg
  end

  def announce
    complete_name = name.split("/")
    file = complete_name.last
    output_dir = complete_name[0..complete_name.length-2]
    msg = "Created '#{file}'"
    msg << " in directory '#{output_dir}'" if name.to_s != output_dir.to_s
    stdout.puts msg
  end

  def fixme
    return unless test ?f, 'Rakefile'
    stdout.puts 'Now you need to fix these files'
    system "#{::Bones::RUBY} -S rake notes"
  end

end  # class Create
end  # module TemplateBuilder::App

# EOF
