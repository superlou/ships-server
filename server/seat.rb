require_relative 'ship'

class Seat
  attr_accessor :ship, :terminal, :socket

  def initialize(terminal, socket)
    @terminal = terminal
    @socket = socket
  end

  def send(msg)
    @socket.send(msg.to_json)
  end
end

class SeatManager
  attr_reader :seats

  def initialize()
    @seats = []
  end

  def add(terminal_id, socket)
    terminal = Terminal.find(terminal_id)
    return nil unless terminal

    existing = @seats.find do |seat|
      seat.terminal == terminal
    end

    if existing
      seat = existing
      seat.socket = socket
    else
      seat = Seat.new(terminal, socket)
      @seats << seat
    end

    seat
  end

  def seat_for(ws)
    @seats.find{|seat| seat.socket == ws}
  end

  def push_states
    @seats.each do |seat|
      seat.send({
        terminal_update: seat.terminal.data_update,
      })
    end
  end
end
