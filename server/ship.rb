require 'eventmachine'
require 'yaml'

class Hash
  def hmap(&block)
    Hash[self.map {|k, v| block.call(k,v) }]
  end
end

class Ship
  attr_accessor :id, :position, :velocity, :acceleration

  def initialize(id)
    @id = id
    @position = [0, 0]
    @velocity = [0, 0.1]
    @acceleration = [0, 0]

    @config = YAML.load_file(File.join(__dir__, 'config/consoles.yaml'))
  end

  def update(dt)
    update_physics(dt)
  end

  def controls(console_id)
    config = @config['consoles'][console_id]['controls']
    return config
  end

  def console_data(console_id)
    data_templates = @config['consoles'][console_id]['data']
    data_templates.hmap do |key, value|
      [key, eval(value)]
    end
  end

  def update_physics(dt)
    @position[0] += @velocity[0] * dt
    @position[1] += @velocity[1] * dt
  end
end
