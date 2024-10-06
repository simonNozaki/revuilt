# frozen_string_literal: true

RSpec.describe Revuilt::CLI::Cli do
  let(:dir) { '' }
  let(:filter_name) { 'date' }
  let(:function_symbol) { '$date' }
  let(:only_write_temporary) { false }
  let(:options) { { dir:, filter_name:, function_symbol:,only_write_temporary: } }
  let(:cli) { described_class.new options }

  describe '#swap_file_deep' do
    context 'current directory has no Vue files' do
      let(:dir) { '/home/auto-test/demo/' }
      let(:convert_lines_spy) { instance_spy 'Cli' }

      before do
        stat_double = instance_double File::Stat, file?: false, directory?: false
        allow(Dir).to receive(:entries).with(dir).and_return %w[. .. Gemfile main.rb]
        allow(File).to receive(:stat).and_return stat_double
        allow(Revuilt::CLI::Cli).to receive(:convert_lines).and_return false
      end

      it 'should do nothing' do
        cli.swap_file_deep dir

        expect(convert_lines_spy).to have_received(:convert_lines).with '/home/auto-test/demo/Gemfile'
      end
    end

    context 'when a directory has directories and Vue files' do
      before do
        allow(Dir).to receive(:entries)
                        .with('/home/auto-test/demo/components')
                        .and_return %w[. .. domain]
        allow(Dir).to receive(:entries)
                        .with('/home/auto-test/demo/components/domain')
                        .and_return %w[. .. Cart.vue CartItem.vue CartItemPayment.vue]
      end

      it 'exec' do
        puts Dir.entries 'components'
      end
    end
  end
end
