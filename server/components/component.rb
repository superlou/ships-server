class Component
  attr_reader :is_source, :energy, :mass, :position

  def initialize(position, mass)
    @is_source = false
    @energy = 0
    @position = position
    @mass = mass
  end

  def charge(dt)
  end

  def cap
  end

  def act (dt, bus)
  end
end
