require 'eventmachine'
require 'yaml'
require_relative 'component_manager'

class Hash
  def hmap(&block)
    Hash[self.map {|k, v| block.call(k,v) }]
  end
end

class Ship
  attr_accessor :id, :position, :velocity, :acceleration

  def initialize(id)
    @cm = ComponentManager.new
    # @cm.add(:bridge, 0, 2, 1000)
    @cm.add(:engine, 0, 0, 1000)
    # @cm.add(:thruster, 5, 0, 100)
    # @cm.add(:thruster, -5, 0, 100)
    @cm.add(:reactor, 0, 0, 2000)

    @id = id
    @position = [0, 0]
    @velocity = [0, 0]
    @acceleration = [0, 0]

    @isAccelerating = false
    @isDecelerating = false

    @config = YAML.load_file(File.join(__dir__, 'config/consoles.yaml'))
  end

  def update(dt)
    update_physics(dt)

    if @acceleration[1] > 0
      @isAccelerating = true
      @isDecelerating = false
    elsif @acceleration[1] < 0
      @isAccelerating = false
      @isDecelerating = true
    else
      @isAccelerating = false
      @isDecelerating = false
    end
  end

  def controls(console_id)
    config = @config['consoles'][console_id]['controls']
    return config
  end

  def console_data(console_id)
    data_templates = @config['consoles'][console_id]['data']
    data = data_templates.hmap do |key, value|
      [key, eval(value)]
    end
    return data
  end

  def execute(details)
    case details
    when 'accelerate'
      @acceleration[1] += 0.1
    when 'decelerate'
      @acceleration[1] += -0.1
    when 'em_stop'
      @velocity[1] = 0
      @acceleration[1] = 0
    end
  end

  def update_physics(dt)
    @position[0] += 0.5 * @acceleration[0] * dt**2 + @velocity[0] * dt
    @velocity[0] += @acceleration[0] * dt
    @position[1] += 0.5 * @acceleration[1] * dt**2 + @velocity[1] * dt
    @velocity[1] += @acceleration[1] * dt

    @cm.update(dt)
  end
end
