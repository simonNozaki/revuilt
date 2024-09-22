# frozen_string_literal: true

module Revuilt
  module Options
    module Errorable
      def errors
        @errors ||= []
      end

      def add_error(error)
        errors << error
      end

      def errors?
        !errors.empty?
      end
    end
  end
end
