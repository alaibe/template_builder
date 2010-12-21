
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
    fileManager.write_action action if action.length>0
  end
  
  def action
    ret = []
    @gems.each { |gem| ret <<  gem.action if gem.action}
    @action.each {  |act| ret << act if act}
    ret
  end
  
  def to_s
    msg = @name+"\n"
    msg += "\tAll gems for this plugin : \n" 
    @gems.each do |gem|  
      msg +="\t\tname => #{gem.name}\n"
      msg +="\t\t\t-source => #{gem.source}\n"
      msg +="\t\t\t-version => #{gem.version}\n"
      msg +="\t\t\t-action => #{gem.action}\n"
    end 
    msg +="\n"
    msg += "\tcommand => #{@command}\n"
    msg +="\n"
    msg += "\tAll actions for this plugin : \n"
    @action.each {  |act| msg+="\taction => #{act.to_s}\n"}
    msg
  end
  
end

class Gem
  attr_reader :action, :version, :source, :name
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