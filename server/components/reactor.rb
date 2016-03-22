require_relative 'component'

class Reactor < Component
  attr_accessor :energy

  def initialize(name, position, mass)
    super(name, position, mass)
    @is_source = true
    @power = 100
    @energy = 0
    @max_energy = 1000
  end

  def charge(dt)
    @energy += @power * dt
  end

  def cap
    @energy = [@energy, @max_energy].min
  end
end
