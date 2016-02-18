require 'eventmachine'
require 'em-websocket'
require 'json'
require_relative './ship'

period = 0.1

EM.run do
  @ships = {
    "0" => Ship.new('0')
  }

  def update(dt)
    @ships.each {|id, ship| ship.update(dt)}
  end

  EM.add_periodic_timer(period) do
    update(period)
  end

  EM::WebSocket.run(host: "127.0.0.1", port: 8081) do |ws|
    ws.onopen do |handshake|
    end

    ws.onmessage do |msg|
      begin
        msg = JSON.parse msg
        ship = msg['ship_id']
        cmd = msg['cmd']
        response = @ships[ship].do(cmd, msg)
        ws.send(response.to_json)
      rescue Exception => e
        puts e.message
      end
    end
  end
end
