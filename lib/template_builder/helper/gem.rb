
module TemplateBuilder::Helper
class Gem
  attr_reader :name, :version, :source
  def initialize(name, version, source)
    @version = version
    @source = source
    @name = name
  end
  
  def gemify
    gem = []
    gem << "'"+@name+"'"
    gem << ", '"+@version+"'" if @version
    gem << ", :"+@source+"" if @source
    gem
  end
end
end