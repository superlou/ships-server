require_relative 'component'

class Numeric
  def clamp(min, max)
    self < min ? min : self > max ? max : self
  end
end

class Thruster < Engine
  def initialize(name, position, rotation, mass)
    super(name, position, rotation, mass)
    @impulse = 0
    @max_impulse = 10
    @energy_efficiency = 1
  end
end
