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
    @body.reset_forces()

    if @isAccelerating
      angle = @body.a
      @body.apply_force(vec2(100, 0).rotate(CP::Vec2.for_angle(angle)), vec2(0, 0))
    end
  end

  def execute(details)
    case details
    when 'accelerate'
      @isAccelerating = true
    when 'em_stop'
      @isAccelerating = false
    end
  end

  def eval_data(template)
    eval(template)
  end

  def terminal_briefs
    @terminals.map{|terminal| terminal.brief}
  end
end
