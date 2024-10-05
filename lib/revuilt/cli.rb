# frozen_string_literal: true

require 'revuilt/loggable'
require 'revuilt/revuilt_option_parser'
require 'revuilt/filter_converter'

module Revuilt
  module CLI
    class Cli
      include Loggable

      attr_reader :argv,
                  :dir,
                  :filter_name,
                  :function_symbol,
                  :only_write_temporary

      def initialize(argv)
        @argv = argv
        options = RevuiltOptionParser.parse_or_raise(argv)

        @dir = options[:dir]
        @filter_name = options[:filter_name]
        @function_symbol = options[:function_symbol]
        @only_write_temporary = options[:only_write_temporary]
      end

      # Main function
      def call
        swap_file_deep(dir)
      end

      def swap_file_deep(dir)
        path_likes = Dir.entries(dir).reject { %w[. ..].include?(_1) }
        path_likes.each do |path_like|
          swap_file(dir, path_like)
        end
      end

      def swap_file(dir, path_like)
        entry = "#{dir}/#{path_like}"
        entry_stat = File.stat(entry)

        if entry_stat.file? && entry.match?(/.vue$/)
          convert_lines(entry)
          return
        end

        return unless entry_stat.directory?

        # Traverse sub directory
        swap_file_deep(entry)
      end

      def readlines_or_raise(path)
        File.readlines(path)
      rescue Errno::ENOENT => e
        logger.error "Error occurred when reading lines of #{path}."
        raise
      end

      # read lines and replace to function when there are some matches
      def convert_lines(entry)
        lines = readlines_or_raise(entry)
        result = FilterConverter.new(lines, filter_name, function_symbol).convert!
        return unless result.converted

        logger.info "Entry #{entry} has been converted to function call with #{result.converted_lines.length} lines."
        replace_to_new_file(result.lines, entry)
      end

      # Write results to temporary file and swap it with original one
      # TODO: swap new file with old one
      def replace_to_new_file(lines, path)
        tmp_file_path = "#{path}.tmp"
        File.delete(tmp_file_path) if File.exist?(tmp_file_path)
        File.open(tmp_file_path, 'w') { |file| file.write(lines.join) }

        # TODO: delete original file(add else-clause)
        return if only_write_temporary
      end
    end

    class << self
      include Loggable

      def replace!(argv)
        cli = Cli.new(argv)
        logger.info 'Start replacing Vue filter syntax...'
        cli.call
        logger.info 'Complete replacing Vue filter syntax.'
      end
    end
  end
end
