module TemplateBuilder::App::Helper
class Parameter
  attr_reader :priority
  attr_accessor :name
  def initialize(opts={})
    @name = opts[:name]
    @priority = opts[:priority]
  end
end
end