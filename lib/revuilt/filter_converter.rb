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

    # Create a new line with converted with function call syntax
    def create_converted_line(line, function_symbol, filter_syntax)
      substrings = line.scan(filter_syntax)
      return if substrings.to_a.empty?

      substrings.to_a.each do |match_text|
        function_call = to_function_call_style(match_text, function_symbol)
        line = line.sub(filter_syntax) { function_call }
      end

      line
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

    def convert_filter_syntax(line, filter_name, function_symbol, head = 0)
      head, tail = get_mustached_range line, head
      return line if tail.nil?

      mustached_text = line[head..tail]
      function_call = to_function_call_style(mustached_text, function_symbol)
      new_line = line.dup
      new_line[head..tail] = function_call

      # End condition to exit all conversions
      return new_line unless new_line.match?(filter_syntax)

      # Traverse rest text that may will be converted
      next_head = tail + (mustached_text.length - function_call.length)
      convert_filter_syntax(new_line, filter_name, function_symbol, next_head)
    end

    def get_mustached_range(line, head)
      has_pipe = false
      tail = 0

      chars = line.split ''
      chars.each.with_index(head) do |_, index|
        next if line.length == index

        char = chars[index]
        next_char = line[index + 1]
        if char == '{' && next_char == '{'
          head = index
          next
        end
        if char == '|'
          has_pipe = true
          next
        end
        if char == '}' && next_char == '}'
          tail = index + 1
          break
        end
      end

      has_pipe ? [head, tail] : nil
    end

    def to_result(lines, converted_lines)
      converted = converted_lines.length.positive?
      Result.new(lines:, converted:, converted_lines:)
    end
  end
end
