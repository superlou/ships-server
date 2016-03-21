require_relative 'model'

class Terminal < Model
  attr_reader :name

  def initialize(config, ship)
    super()
    @name = config[:name]
    @controls = config[:controls]
    @data = config[:data]
    @ship = ship
  end

  def brief
    {
      id: self.id,
      name: @name,
      ship_id: @ship.id
    }
  end

  def snapshot
    {
      id: self.id,
      name: @name,
      ship_id: @ship.id,
      controls: @controls,
      terminalData: generate_data
    }
  end

  def generate_data
    data_templates = @data
    data = data_templates.hmap do |key, value|
      [key, @ship.eval_data(value)]
    end
    return data
  end
end
