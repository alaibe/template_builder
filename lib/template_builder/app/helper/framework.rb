
module TemplateBuilder::App::Helper
  
  def self.framework_factory(opts = {})
    gems = []
    puts opts[:gems]
    opts[:gems].each { |gem| gems<< Gem.new(gem) }
    opts[:gems] = gems
    Framework.new opts
  end
  
class Framework
  attr_reader :name, :gems, :action, :command
  def initialize(opts = {})
    @name = opts[:name]
    @gems = opts[:gems]
    @action = opts[:action]
    @command = opts[:command]
  end
  
  def write(fileManager)
    @gems.each{ |gem| fileManager.write_gem gem.to_s }
  end
end

class Gem
  attr_reader :name, :version, :source, :action
  def initialize(opts = {})
    @version = opts[:version]
    @source = opts[:source]
    @name = opts[:name]
    @action = opts[:action]
  end
  
  def to_s
    gem = "'"+@name+"'"
    gem += ", '"+@version+"'" if @version
    gem += ", :"+@source+"" if @source
    gem
  end
end
end