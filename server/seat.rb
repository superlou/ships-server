class Seat
  attr_accessor :ship, :console_id, :socket

  def initialize(ship, console_id, socket)
    @ship = ship
    @console_id = console_id
    @socket = socket
  end

  def send(msg)
    @socket.send(msg.to_json)
  end
end

class SeatManager
  attr_reader :seats

  def initialize(ships=[])
    @seats = []
    @ships = ships
  end

  def add(ship_id, console_id, socket)
    ship = @ships[ship_id]
    return nil unless ship

    existing = @seats.find do |seat|
      seat.ship == ship and seat.console_id == console_id
    end

    if existing
      seat = existing
      seat.socket = socket
    else
      seat = Seat.new(ship, console_id, socket)
      @seats << seat
    end

    seat
  end

  def seat_for(ws)
    @seats.find{|seat| seat.socket == ws}
  end

  def push_states
    @seats.each do |seat|
      data = {}
      data['console_data'] = seat.ship.console_data(seat.console_id)
      data['console_id'] = seat.console_id
      data['ship_id'] = seat.ship.id
      data['response_type'] = :data_update
      seat.send(data)
    end
  end
end
