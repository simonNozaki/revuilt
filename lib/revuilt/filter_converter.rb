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

      @filter_syntax = Regexp.new(/{{ [0-9a-zA-Z._]+ \| #{filter_name} }}/)
    end

    def convert!
      converted_lines = []
      lines.each_with_index do |line, index|
        next unless filter_syntax.match?(line)

        content = create_converted_line(line, function_symbol, filter_syntax)
        converted_lines << { content:, index: }
      end

      # Search filter-replaced line and update the array of lines
      converted_lines.each { |replaced_line| lines[replaced_line[:index]] = replaced_line[:content] }

      to_result(lines, converted_lines)
    end

    # Create a new line with converted with function call syntax
    def create_converted_line(line, function_symbol, filter_syntax)
      match_data = filter_syntax.match(line)
      return if match_data.to_a.empty?

      # TODO: Actually, it's necessary to replace in the same way for multiple elements
      match_text = match_data.to_a[0]
      tokens = match_text.split ' '
      # The second element of split tokens should arguments of function calling( {{ e.item.price | price }} )
      arg = tokens[1]
      # Vue apps should use filter syntax in template, so wrap function call in double braces
      function_call = "{{ #{function_symbol}(#{arg}) }}"

      line.gsub(filter_syntax) { function_call }
    end

    def to_result(lines, converted_lines)
      converted = converted_lines.length.positive?
      Result.new(lines:, converted:, converted_lines:)
    end
  end
end
