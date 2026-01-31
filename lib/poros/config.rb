module Poros
  module Config
    def self.configuration
      @configuration ||= {
        permitted_classes: [Symbol],
      }
    end

    def self.configure
      yield(configuration)
    end
  end
end
