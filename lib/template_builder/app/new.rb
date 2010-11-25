
module TemplateBuilder::App
class New < Command

  def self.initialize_new
    synopsis 'template_builder new template_name [options]'

    summary 'create a new template in consequence of your choice'

    description <<-__
Create a new template in consequence of your choice. You can add a lot
of option as the database, the javascript framework etc .. 
    __
    
    option(standard_options[:directory])
    option(standard_options[:verbose])
  end

  def self.in_output_directory( *args )
    @in_output_directory ||= []
    @in_output_directory.concat(args.map {|str| str.to_sym})
    @in_output_directory
  end

  def run
    raise Error, "Output directory #{output_dir.inspect} already exists." if test ?e, output_dir

    copy_files
    announce

    in_directory(output_dir) {
      self.class.in_output_directory.each {|cmd| self.send cmd}
      fixme
    }
  end

  def parse( args )
    opts = super args
    
    config[:name] = args.empty? ? nil : args.join('_')
    config[:output_dir] = name if output_dir.nil?
    if name.nil?
      stdout.puts opts
      exit 1
    end
  end

  def copy_files
    fm = FileManager.new(
      :source => repository || skeleton_dir,
      :destination => output_dir,
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
    msg = "Created '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
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
