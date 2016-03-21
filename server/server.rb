require 'eventmachine'
require 'em-websocket'
require 'json'
require 'chipmunk'
require_relative 'ship'
require_relative 'seat'
require_relative 'hash'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/components/*') {|file| require file}

period = 0.1

EM.run do
  Ship.new('twocatred')

  @seat_manager = SeatManager.new(@ships)

  @space = CP::Space.new
  Ship.all.each do |ship|
    @space.add_body(ship.body)
  end

  def update(dt)
    Ship.all.each {|ship| ship.update(dt)}
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
        terminal_id = Integer(msg['terminal_id'])
        ws.send({
          terminal: Terminal.find(terminal_id).snapshot
        }.to_json)
      elsif cmd == "command"
        ship = @seat_manager.seat_for(ws).ship
        ship.execute(msg['data'])
      elsif cmd == "joinShip"
        ship_id = Integer(msg['shipCode'])
        ws.send({
          terminalBriefs: Ship.find(ship_id).terminal_briefs
        }.to_json)
      end
    end
  end
end
