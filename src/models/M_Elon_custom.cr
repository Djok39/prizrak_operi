module ElonCustom
  def to_s(io)
    io << @id
  end

  macro included
    def self.take
      raise "not implemented"
    end# self.take
  end
end
