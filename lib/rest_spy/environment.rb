module RestSpy
  class Environment
    def self.mute?
      not ENV["MUTE"].nil?
    end
  end
end