class Component
  attr_reader :is_source, :energy, :mass, :position, :name

  def initialize(name, position, mass)
    @name = name
    @is_source = false
    @energy = 0
    @position = position
    @mass = mass
  end

  def charge(dt)
  end

  def cap
  end

  def act (dt, ship, bus)
  end
end
