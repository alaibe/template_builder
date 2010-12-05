
module TemplateBuilder::App::Helper
  
  def self.framework_factory(opts = {})
    gems = []
    opts[:gems].each { |gem| gems<< Gem.new(gem) }
    opts[:gems] = gems
    Framework.new opts
  end
  
class Framework
  attr_reader  :command
  def initialize(opts = {})
    @name = opts[:name]
    @gems = opts[:gems]
    @action = opts[:action]
    @command = opts[:command]
  end
  
  def run(fileManager)
    @gems.each { |gem| fileManager.write_gem gem.to_s }
    fileManager.write_action action.to_s if action.length>0
  end
  
  def action
    ret = []
    @gems.each { |gem| ret <<  gem.action+"\n" if gem.action}
    ret << "\t"+@action+"\n" if @action
    ret
  end
end

class Gem
  attr_reader :action
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