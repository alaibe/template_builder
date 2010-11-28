class Framework
  attr_reader :name, :gems, :action
  def initialize(name, gems, action)
    @name = name
    @gems = gems
    @action = action
  end
end