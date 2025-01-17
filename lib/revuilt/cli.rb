# frozen_string_literal: true

require 'revuilt/loggable'
require 'revuilt/revuilt_option_parser'
require 'revuilt/filter_converter'

module Revuilt
  module CLI
    class Cli
      include Loggable

      attr_reader :dir,
                  :only_write_temporary

      def initialize(options)
        raise ArgumentError unless options.is_a? Hash

        @dir = options[:dir]
        @only_write_temporary = options[:only_write_temporary]
        @filter_converter = FilterConverter.new options[:filter_name], options[:function_symbol]
      end

      def call
        swap_file_deep dir
      end

      def swap_file_deep(dir)
        Dir.entries(dir).reject { %w[. ..].include?(_1) }.each do |path_like|
          entry = "#{dir}/#{path_like}"
          entry_stat = File.stat entry

          if entry_stat.file? && entry.match?(/.vue$/)
            convert_lines entry
            next
          end

          # Traverse sub directory
          swap_file_deep entry if entry_stat.directory?
        end
      end

      # read lines and replace to function when there are some matches
      def convert_lines(entry)
        lines = File.readlines entry
        result = @filter_converter.convert! lines
        return false unless result.converted

        logger.info "Entry #{entry} has been converted to function call with #{result.converted_lines.length} lines."
        replace_to_new_file(result.lines, entry)
        true
      rescue Errno::ENOENT
        logger.error "Error occurred when reading lines of #{path}."
        raise
      end

      # Write results to temporary file and swap it with original one
      def replace_to_new_file(lines, path)
        tmp_file_path = "#{path}.tmp"
        File.delete tmp_file_path if File.exist? tmp_file_path
        File.open(tmp_file_path, 'w') { _1.write lines.join }

        return if only_write_temporary

        File.rename tmp_file_path, path
      end
    end

    class << self
      include Loggable

      def replace!(argv)
        options = RevuiltOptionParser.parse_or_raise argv
        cli = Cli.new options

        logger.info 'Start replacing Vue filter syntax...'
        cli.call
        logger.info 'Complete replacing Vue filter syntax.'
      end
    end
  end
end
