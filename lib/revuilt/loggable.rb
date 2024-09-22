# frozen_string_literal: true

require 'logger'

module Revuilt
  module Loggable
    def logger
      @logger ||= Logger.new $stdout
    end
  end
end
