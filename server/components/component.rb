class Component
  attr_reader :is_source, :energy

  def initialize
    @is_source = false
    @energy = 0
  end

  def charge(dt)
  end

  def cap
  end

  def act (dt, bus)
  end
end
