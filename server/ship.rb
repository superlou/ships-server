require 'eventmachine'
require 'yaml'
require 'chipmunk'
require_relative 'component_manager'
require_relative 'model'
require_relative 'terminal'

class Ship < Model
  attr_accessor :id, :code, :body

  def initialize(code=nil)
    super()

    config = load_config('ship1')

    @cm = ComponentManager.new(self)
    config[:components].each do |component|
      @cm.add_from_config(component)
    end

    @body = CP::Body.new(@cm.mass, @cm.moi)

    @isAccelerating = false
    @isTurningLeft = false
    @isTurningRight = false

    @terminals = config[:terminals].map do |terminal|
      Terminal.new(terminal, self)
    end
  end

  def com
    @cm.com
  end

  def load_config(file)
    config = YAML.load_file(File.join(__dir__, "config/#{file}.yaml"))
    config = config.deep_symbolize_keys
    return config
  end

  def update(dt)
    @cm.update(dt)

    engine_impulse = @isAccelerating ? 40 : 0
    thruster_right_impulse = @isTurningLeft ? 10 : 0
    thruster_left_impulse = @isTurningRight ? 10 : 0

    @cm.get('engine').set_impulse(engine_impulse)
    @cm.get('thruster_right').set_impulse(thruster_right_impulse)
    @cm.get('thruster_left').set_impulse(thruster_left_impulse)
  end

  def execute(details)
    case details
    when 'accelerate'
      @isAccelerating = !@isAccelerating
    when 'thrust_left'
      @isTurningLeft = !@isTurningLeft
      @isTurningRight = false
    when 'thrust_right'
      @isTurningRight = !@isTurningRight
      @isTurningLeft = false
    end
  end

  def eval_data(template)
    eval(template)
  end

  def terminal_briefs
    @terminals.map{|terminal| terminal.brief}
  end
end
