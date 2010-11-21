class Framework
  attr_reader :name, :gems
  def initialize(name, gems)
    @name = name
    @gems = gems
  end
end