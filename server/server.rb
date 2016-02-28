require 'eventmachine'
require 'em-websocket'
require 'json'
require 'chipmunk'
require_relative './ship'
require_relative './seat'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/components/*') {|file| require file}

period = 0.1

EM.run do
  @ships = {
    "0" => Ship.new('0')
  }

  @seat_manager = SeatManager.new(@ships)

  @space = CP::Space.new
  @ships.each do |id, ship|
    @space.add_body(ship.body)
  end

  def update(dt)
    @ships.each {|id, ship| ship.update(dt)}
    @seat_manager.push_states
  end

  EM.add_periodic_timer(period) do
    update(period)
    @space.step(period)
  end

  EM::WebSocket.run(host: "127.0.0.1", port: 8081) do |ws|
    ws.onopen do |handshake|
    end

    ws.onmessage do |msg|
      puts msg

      begin
        msg = JSON.parse msg
      rescue Exception => e
        puts e.message
        return
      end

      ship_id = msg['ship_id']
      cmd = msg['cmd']

      if cmd == "subscribe"
        console_id = msg['console_id']
        seat = @seat_manager.add(ship_id, console_id, ws)
        response = {controls: @ships[ship_id].controls(console_id)}
        response['ship_id'] = ship_id
        response['console_id'] = console_id
        response['response_type'] = 'console_config'
        seat.send(response)
      elsif cmd == "command"
        ship = @seat_manager.seat_for(ws).ship
        ship.execute(msg['data'])
      end
    end
  end
end
