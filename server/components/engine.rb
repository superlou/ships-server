require_relative 'component'

class Engine < Component
  def initialize(position, mass)
    super(position, mass)
    @impulse = 0
    @max_impulse = 100
    @energy_efficiency = 1
  end

  def act(dt, bus)
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
  end
end
