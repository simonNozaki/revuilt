# frozen_string_literal: true

RSpec.describe Revuilt::FilterConverter do
  let(:lines) { [] }
  let(:filter_name) { 'date' }
  let(:function_symbol) { '$date' }

  let(:converter) { described_class.new(lines, filter_name, function_symbol) }

  describe '#convert!' do
    context 'when lines have no replacement targets' do
      let(:lines) { ['<section>', '  <h1>Title</h1>', '</div>'] }

      it 'should return original lines' do
        results = converter.convert!

        expect(results.converted).to eq false
        expect(results.lines).to eq lines
      end
    end

    context 'when there are some lines with Vue filter syntax' do
      let(:lines) { ['{{ payedAt | date }}', '{{ item.price | price }}'] }

      it 'replaces the filter syntax with the function call' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq ['{{ $date(payedAt) }}', '{{ item.price | price }}']
      end
    end
  end
end
