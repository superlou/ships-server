require_relative 'component'

class Numeric
  def clamp(min, max)
    self < min ? min : self > max ? max : self
  end
end

class Engine < Component
  def initialize(name, position, rotation, mass)
    super(name, position, rotation, mass)
    @impulse = 0
    @max_impulse = 100
    @energy_efficiency = 1
  end

  def set_impulse(impulse)
    @impulse = impulse.clamp(0, @max_impulse)
  end

  def act(dt, ship, bus)
    available = bus.available_energy

    needed_energy = @impulse / @energy_efficiency

    if needed_energy < available
      bus.drain(needed_energy)
      impulse = @impulse
    else
      bus.drain(available)
      impulse = available * @energy_efficiency
    end

    force = impulse / dt

    angle = ship.body.a + @rotation
    ship.body.apply_force(vec2(force, 0).rotate(CP::Vec2.for_angle(angle)),
                          @position - ship.com)
  end
end
