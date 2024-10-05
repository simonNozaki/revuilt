# frozen_string_literal: true

module Revuilt

  # Filter converter class.
  # Search Vue filter syntax and replace it with function call syntax
  class FilterConverter
    # PORO for result of conversion
    Result = Struct.new(:lines, :converted, :converted_lines, keyword_init: true)

    attr_reader :lines,
                :function_symbol,
                :filter_name,
                :filter_syntax

    def initialize(lines, filter_name, function_symbol)
      @lines = lines
      @filter_name = filter_name
      @function_symbol = function_symbol

      # e.g. {{ getTax(stockItem.price ?? 0) | price }}
      @filter_syntax = Regexp.new(/{{.*\| *#{filter_name} *}}/)
    end

    def convert!
      converted_lines = []
      lines.each_with_index do |line, index|
        while line.match?(filter_syntax)
          converted_line = convert_filter_syntax(line, filter_name, function_symbol)

          converted_lines << { content: converted_line, index: }
          line = converted_line
        end
      end

      # Search filter-replaced line and update the array of lines
      converted_lines.each { |replaced_line| lines[replaced_line[:index]] = replaced_line[:content] }

      to_result(lines, converted_lines)
    end

    def convert_filter_syntax(line, filter_name, function_symbol, head = 0)
      head, tail = find_mustache_bounds line, head
      return line if tail.nil?

      mustached_text = line[head..tail]
      function_call = to_function_call_style(mustached_text, function_symbol)
      new_line = line.dup
      new_line[head..tail] = function_call

      # End condition to exit all conversions
      return new_line unless new_line.match?(filter_syntax)

      # Traverse rest text that may have convertable texts
      next_head = tail + (mustached_text.length - function_call.length)
      convert_filter_syntax(new_line, filter_name, function_symbol, next_head)
    end

    # Get mustached range including Vue filter syntax
    def find_mustache_bounds(line, head)
      start_match = line.match /{{/, head
      mustache_start = start_match&.begin(0)
      end_match = line.match /}}/, head
      mustache_end = end_match ? end_match.end(0) - 1 : nil
      return if mustache_start.nil? || mustache_end.nil?

      has_pipe = line[mustache_start, mustache_end].include? '|'

      has_pipe ? [mustache_start, mustache_end] : nil
    end

    # Format original Vue filter syntax to function call string
    def to_function_call_style(text, function_symbol)
      first_text = text.split('|')[0]
      return nil if first_text.nil?

      # Slice heading `{{`
      expression = first_text[2..first_text.length]
      arg = expression.strip

      "{{ #{function_symbol}(#{arg}) }}"
    end

    def to_result(lines, converted_lines)
      converted = converted_lines.length.positive?
      Result.new(lines:, converted:, converted_lines:)
    end
  end
end
