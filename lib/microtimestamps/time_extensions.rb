module MicroTimestamps
  module TimeExtensions

    def to_microtime
      (self.to_f * 1000000.0).to_i
    end

  end
end

