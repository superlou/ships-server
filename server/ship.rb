require 'eventmachine'

class Ship
  attr_accessor :id, :position, :velocity, :acceleration

  def initialize(id)
    @id = id
    @position = [0, 0]
    @velocity = [0, 0.1]
    @acceleration = [0, 0]
  end

  def update(dt)
    update_physics(dt)
  end

  def console_config(console_id)
    case console_id
    when '0'
      console_config = {
        response_type: 'console_config',
        ship_id: @id,
        console_id: console_id,
        controls: [
          {
            name: 'accelerate',
            type: 'control-button',
            label: 'accelerate',
          },
          {
            name: 'em_stop',
            type: 'control-button',
            label: 'em stop'
          },
          {
            name: 'position_x',
            type: 'control-labeled-data',
            label: 'X-Pos',
            bind: 'position_x',
            decimals: '2'
          },
          {
            name: 'position_y',
            type: 'control-labeled-data',
            label: 'Y-Pos',
            bind: 'position_y',
            decimals: '2'
          }
        ]
      }
    when '1'
      console_config = {
        response_type: 'console_config',
        ship_id: @id,
        console_id: console_id,
        controls: [
          {
            type: 'control-labeled-data',
            label: 'position-x',
            bind: 'position_x'
          },
          {
            type: 'control-labeled-data',
            label: 'position-y',
            bind: 'position_y'
          }
        ]
      }
    end

    return console_config
  end

  def console_data(console_id)
    case console_id
    when '0'
      {
        position_x: @position[0],
        position_y: @position[1]
      }
    when '1'
      {
        position_x: @position[0],
        position_y: @position[1]
      }
    else
      { }
    end
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
            },
            {
              type: 'control-labeled-data',
              label: 'position-y',
              value: 0
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
