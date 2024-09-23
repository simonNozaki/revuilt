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

      @filter_syntax = Regexp.new(/{{ *[0-9a-zA-Z._()]+ *\| *#{filter_name} *}}/)
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
      # Match data is only matched Vue filter calling
      match_text = match_data.to_a[0]
      function_call = to_function_call_style(match_text, filter_name, function_symbol)

      line.gsub(filter_syntax) { function_call }
    end

    # Format original Vue filter syntax to function call string
    def to_function_call_style(text, filter_name, function_symbol)
      # Split and remove template elements
      tokens = text.split(/[{}| ]/)
      function_args = tokens.reject { ['', filter_name].include?(_1) }
      return if function_args.empty?

      arg = function_args[0]
      # Vue apps should use filter syntax in template, so wrap function call in double braces
      "{{ #{function_symbol}(#{arg}) }}"
    end

    def to_result(lines, converted_lines)
      converted = converted_lines.length.positive?
      Result.new(lines:, converted:, converted_lines:)
    end
  end
end
