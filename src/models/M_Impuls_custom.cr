module ImpulsCustom
  def to_s(io)
    io << @microwave_id << "|" << @logic << "|" << @strength << "|" << @edge << "|" << @ns100
  end

  macro included
    def self.take
      raise "not implemented"
    end# self.take
  end
end
