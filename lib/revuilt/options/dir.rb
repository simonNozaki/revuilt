# frozen_string_literal: true

require 'revuilt/options/errorable'

module Revuilt
  module Options
    class Dir
      include Errorable

      attr_reader :value

      def initialize(value)
        add_error 'Target directory should not be blank.' unless value.is_a?(String) || value == ''

        @value = value
      end
    end
  end
end
