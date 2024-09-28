# frozen_string_literal: true

require 'optparse'
require 'revuilt/options/dir'
require 'revuilt/options/filter_name'
require 'revuilt/options/function_symbol'

module Revuilt
  # CLI option parser. Check option is valid and create options object parsing ARGV
  class CliOptionParser
    # FIXME: maybe redundant including
    include Options

    attr_reader :dir,
                :filter_name,
                :function_symbol,
                :option_parser

    def initialize
      @dir = Dir.new('')
      @filter_name = FilterName.new('')
      @function_symbol = FunctionSymbol.new('')

      @option_parser = build_option_parser
    end

    def parse_or_raise(argv)
      option_parser.parse argv
      assert_options

      {
        dir: dir.value,
        filter_name: filter_name.value,
        function_symbol: function_symbol.value
      }
    end

    # Assert CLI args are all valid
    def assert_options
      error_messages = [dir, filter_name, function_symbol].filter(&:errors?).flat_map(&:errors)
      return unless error_messages.length.positive?

      message = error_messages.join('; ')
      raise ArgumentError, message
    end

    # rubocop:disable Metrics/MethodLength
    def build_option_parser
      OptionParser.new do |parser|
        parser.banner = 'Usage: revuilt [options]'

        parser.on('-d', '--dir DIR', 'Target directory to convert') { @dir = Dir.new(_1) }
        parser.on('-f', '--filter-name FILTER_NAME', 'Vue filter name to convert') do
          @filter_name = FilterName.new(_1)
        end
        parser.on('-s', '--function-symbol FUNCTION_SYMBOL', 'Converting function name alternative to Vue filter') do
          @function_symbol = FunctionSymbol.new(_1)
        end
        parser.on('-t', '--only-write-temporary', 'Only write .tmp file when this flag is true') do
          @only_write_temporary = _1
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    class << self
      def parse_or_raise(argv)
        CliOptionParser.new.parse_or_raise argv
      end
    end
  end
end
