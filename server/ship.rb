require 'eventmachine'

class Ship
  attr_accessor :id, :position, :velocity, :acceleration

  def initialize(id)
    @id = id
    @position = [0, 0]
    @velocity = [0, 0]
    @acceleration = [0, 0]
  end

  def update(dt)
    update_physics(dt)
  end

  def do(cmd, data)
    if cmd == "subscribe"
      puts "Subscribing"
      puts data

      if data['console_id'] == '0'
        console_config = {
          response_type: 'console_config',
          ship_id: @id,
          console_id: data['console_id'],
          controls: [
            {
              type: 'control-button',
              label: 'accelerate'
            },
            {
              type: 'control-button',
              label: 'em stop'
            }
          ]
        }
      elsif data['console_id'] == '1'
        console_config = {
          response_type: 'console_config',
          ship_id: @id,
          console_id: data['console_id'],
          controls: [
            {
              type: 'control-labeled-data',
              label: 'position-x'
            },
            {
              type: 'control-labeled-data',
              label: 'position-y'
            }
          ]
        }
      end

      return console_config
    end
  end

  # def apply_queue
  #   while @commands.size
  #     @commands.pop
  #   end
  # end

  def update_physics(dt)
    @position[0] += @velocity[0] * dt
    @position[1] += @velocity[1] * dt
  end
end
