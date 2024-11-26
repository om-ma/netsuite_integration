module SpreeNetsuiteIntegration
  class Configuration
    attr_accessor :api_key, :endpoint

    def initialize
      @api_key = nil
      @endpoint = nil
    end
  end
end