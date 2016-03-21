require 'eventmachine'
require 'yaml'
require 'chipmunk'
require_relative 'component_manager'
require_relative 'model'
require_relative 'terminal'

class Ship < Model
  attr_accessor :id, :code, :position, :velocity, :acceleration, :body

  def initialize(code=nil)
    super()

    @cm = ComponentManager.new
    # @cm.add(:bridge, 0, 2, 1000)
    @cm.add(:engine, -5, 0, 1000)
    # @cm.add(:thruster, 5, 0, 100)
    # @cm.add(:thruster, -5, 0, 100)
    @cm.add(:reactor, -2, 0, 2000)

    @body = CP::Body.new(@cm.mass, @cm.moi)

    @position = [0, 0]
    @velocity = [0, 0]
    @acceleration = [0, 0]

    @isAccelerating = false
    @isDecelerating = false

    config = load_config('ship1')
    @terminals = config[:terminals].map do |terminal|
      Terminal.new(terminal, self)
    end
  end

  def load_config(file)
    config = YAML.load_file(File.join(__dir__, "config/#{file}.yaml"))
    config = config.deep_symbolize_keys
    return config
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

  def terminal_briefs
    @terminals.map{|terminal| terminal.brief}
  end

  def eval_data(template)
    eval(template)
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
