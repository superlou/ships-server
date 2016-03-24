class Component
  attr_reader :is_source, :energy, :mass, :position, :rotation, :name

  def initialize(name, position, rotation, mass)
    @name = name
    @is_source = false
    @energy = 0
    @position = position
    @rotation = rotation
    @mass = mass
  end

  def charge(dt)
  end

  def cap
  end

  def act (dt, ship, bus)
  end
end
