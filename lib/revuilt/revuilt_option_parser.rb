# frozen_string_literal: true

require 'optparse'

module Revuilt
  # CLI option parser. Check option is valid and create options object parsing ARGV
  class RevuiltOptionParser
    def initialize
      @option_parser = build_option_parser
    end

    def parse_or_raise(argv)
      @option_parser.parse argv

      {
        dir: @dir,
        filter_name: @filter_name,
        function_symbol: @function_symbol,
        only_write_temporary: @only_write_temporary
      }
    end

    # rubocop:disable Metrics/MethodLength
    def build_option_parser
      OptionParser.new do |parser|
        parser.banner = 'Usage: revuilt [options]'

        parser.on('-d', '--dir=DIR', 'Target directory to convert') { @dir = _1 }
        parser.on('-f', '--filter-name=FILTER_NAME', 'Vue filter name to convert') { @filter_name = _1 }
        parser.on('-s', '--function-symbol=FUNCTION_SYMBOL', 'Converting function name alternative to Vue filter') do
          @function_symbol = _1
        end
        parser.on('-t', '--only-write-temporary', 'Only write .tmp file when this flag is true') do
          @only_write_temporary = _1
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    class << self
      def parse_or_raise(argv)
        RevuiltOptionParser.new.parse_or_raise argv
      end
    end
  end
end
