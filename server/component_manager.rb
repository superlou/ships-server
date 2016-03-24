require 'active_support/inflector'

class ComponentManager
  attr_reader :bus

  def initialize(ship)
    @bus = Bus.new
    @ship = ship
    @components = []
  end

  def add(component_class, name, pos_x, pos_y, rotation, mass, options={})
    klass = component_class.to_s.camelize.constantize
    component = klass.new(name,
                          vec2(pos_x, pos_y),
                          rotation * 3.1415 / 180.0,
                          mass)
    @components << component
    @bus.register(component)
  end

  def add_from_config(config)
    component_class = config[:class] || config[:name]
    config[:rotation] ||= 0
    add(component_class,
        config[:name],
        config[:position][0].to_i,
        config[:position][1].to_i,
        config[:rotation].to_i,
        config[:mass])
  end

  def update(dt)
    @ship.body.reset_forces()
    @bus.charge(dt)
    @components.map{|component| component.act(dt, @ship, @bus)}
    @bus.cap()
  end

  def mass
    @components.map(&:mass).reduce(:+)
  end

  def com
    x = @components.map{|c| c.position.x * c.mass}.reduce(:+) / mass
    y = @components.map{|c| c.position.y * c.mass}.reduce(:+) / mass
    vec2(x, y)
  end

  def moi
    mois = @components.map do |component|
      r_x = component.position.x - com.x
      r_y = component.position.y - com.y
      r = Math::sqrt(r_x ** 2 + r_y ** 2)
      component.mass * (r ** 2)  # could remove sqrt and squaring
    end

    mois.reduce(:+)
  end

  def get(name)
    @components.find{|component| component.name == name}
  end
end

class Bus
  def initialize
    @sources = []
    @sinks = []
    @components = @sources + @sinks
  end

  def register(component)
    if component.is_source
      @sources << component
    else
      @sinks << component
    end

    @components << component
  end

  def charge(dt)
    @sources.each{|source| source.charge(dt)}
  end

  def cap
    @components.each{|component| component.cap()}
  end

  def available_energy
    @sources.map{|source| source.energy}.reduce(:+)
  end

  def drain(drained_energy)
    @sources.each do |source|
      source_energy = source.energy

      if drained_energy > source_energy
        drained_energy -= source_energy
        source.energy = 0
      else
          source.energy -= drained_energy
          break
      end
    end
  end
end
