require 'active_support/inflector'

class ComponentManager
  def initialize
    @bus = Bus.new
    @components = []
  end

  def add(component_class, pos_x, pos_y, mass, options={})
    klass = component_class.to_s.camelize.constantize
    component = klass.new([pos_x, pos_y], mass)
    @components << component
    @bus.register(component)
  end

  def update(dt)
    @bus.charge(dt)
    actions = @components.map{|component| component.act(dt, @bus)}
    @bus.cap()
  end

  def mass
    @components.map(&:mass).reduce(:+)
  end

  def com
    x = @components.map{|c| c.position[0] * c.mass}.reduce(:+) / mass
    y = @components.map{|c| c.position[1] * c.mass}.reduce(:+) / mass
    [x, y]
  end

  def moi
    mois = @components.map do |component|
      r_x = component.position[0] - com[0]
      r_y = component.position[1] - com[1]
      r = Math::sqrt(r_x ** 2 + r_y ** 2)
      component.mass * (r ** 2)  # could remove sqrt and squaring
    end
    
    mois.reduce(:+)
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
