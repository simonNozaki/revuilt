# frozen_string_literal: true

require 'optparse'

RSpec.describe Revuilt::RevuiltOptionParser do
  let(:parser) { described_class.new }

  # rubocop:disable Metrics/BlockLength
  describe '#parse_or_raise' do
    context 'when passing no option args' do
      it 'should raise error' do
        expect { described_class.parse_or_raise %w[-d] }.to raise_error OptionParser::MissingArgument
      end
    end

    context 'when passing unknown args' do
      it 'should raise error' do
        expect { described_class.parse_or_raise %w[-x] }.to raise_error OptionParser::InvalidOption
      end
    end

    context 'when passing required args' do
      it 'should return option object' do
        options = described_class.parse_or_raise %w[-d dir -f currencyJa -s $currency]

        expect(options).to eq(
          dir: 'dir',
          filter_name: 'currencyJa',
          function_symbol: '$currency',
          only_write_temporary: nil
        )
      end
    end

    context 'when passing with only write temporary' do
      it 'should return option object' do
        options = described_class.parse_or_raise %w[-d dir -f currencyJa -s $currency -t]

        expect(options).to eq(
          dir: 'dir',
          filter_name: 'currencyJa',
          function_symbol: '$currency',
          only_write_temporary: true
        )
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
