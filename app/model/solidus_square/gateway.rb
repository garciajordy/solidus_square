# frozen_string_literal: true

require 'square'

module SolidusSquare
  class Gateway
    attr_accessor :client

    def initialize
      @client = ::Square::Client.new(
        access_token: ::SolidusSquare.config.square_access_token,
        environment: ::SolidusSquare.config.square_environment
      )
    end
  end
end