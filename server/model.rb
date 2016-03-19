module ModelMixin
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def add(model)
      @collection = (@collection || []) << model
    end

    def next_id
      @counter = 0 if @counter.nil?
      @counter += 1
      return @counter - 1
    end

    def all
      @collection || []
    end

    def find(id)
      @collection.find{|model| model.id == id}
    end
  end

  attr_reader :id

  def initialize
    self.class.add(self)
    @id = self.class.next_id
  end
end

class Model
  include ModelMixin
end
