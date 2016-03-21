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
    if @body.f.y > 0
      @isAccelerating = true
      @isDecelerating = false
    elsif @body.f.y < 0
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
      @body.reset_forces()
      @body.apply_force(vec2(0, 100), vec2(0, 0))
    when 'decelerate'
      @body.reset_forces()
      @body.apply_force(vec2(0, -100), vec2(0, 0))
    when 'em_stop'
      @body.reset_forces()
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
