# frozen_string_literal: true

RSpec.describe Revuilt::CLI::Cli do
  let(:dir) { '' }
  let(:filter_name) { 'date' }
  let(:function_symbol) { '$date' }
  let(:only_write_temporary) { false }
  let(:options) { { dir:, filter_name:, function_symbol:, only_write_temporary: } }
  let(:cli) { described_class.new options }
  let(:cli_spy) { instance_spy 'Cli' }

  # rubocop:disable Metric/BlockLength
  describe '#swap_file_deep' do
    context 'current directory has no Vue files' do
      let(:dir) { '/home/auto-test/demo/' }

      before do
        stat_double = instance_double File::Stat, file?: true, directory?: false
        allow(Dir).to receive(:entries).with(dir).and_return %w[. .. Gemfile main.rb]
        allow(File).to receive(:stat).and_return stat_double
        allow(cli).to receive(:convert_lines).with('/home/auto-test/demo/Gemfile').and_return false
      end

      it 'should do nothing' do
        cli.swap_file_deep dir

        expect(cli_spy).not_to have_received(:convert_lines).with('/home/auto-test/demo/main.rb')
        expect(cli_spy).not_to have_received(:convert_lines).with('/home/auto-test/demo/Gemfile')
      end
    end

    context 'when several Vue files has no Vue filter syntaxes' do
      let(:dir) { '/home/auto-test/demo/components' }

      before do
        allow(Dir).to receive(:entries)
          .with('/home/auto-test/demo/components')
          .and_return %w[. .. Cart.vue CartItem.vue CartItemPayment.vue]
        %w[Cart.vue CartItem.vue CartItemPayment.vue].each do |entry|
          path = "/home/auto-test/demo/components/#{entry}"
          allow(File).to receive(:stat).with(path).and_return instance_double File::Stat, file?: true, directory?: false
          allow(cli).to receive(:convert_lines).with(path).and_return false
        end
      end

      it 'should not convert anything' do
        cli.swap_file_deep dir

        expect(cli).to have_received(:convert_lines).with '/home/auto-test/demo/components/Cart.vue'
        expect(cli).to have_received(:convert_lines).with '/home/auto-test/demo/components/CartItem.vue'
        expect(cli).to have_received(:convert_lines).with '/home/auto-test/demo/components/CartItemPayment.vue'
      end
    end

    context 'when a directory has nested directory and Vue files' do
      let(:dir) { '/home/auto-test/components' }

      before do
        allow(Dir).to receive(:entries).with('/home/auto-test/components').and_return %w[. .. README.md Cart.vue cart]
        '/home/auto-test/components/Cart.vue'.then do |entry|
          allow(File).to receive(:stat).with(entry).and_return instance_double File::Stat, file?: true,
                                                                                           directory?: false
          allow(cli).to receive(:convert_lines).with(entry).and_return true
        end
        allow(File).to receive(:stat)
          .with('/home/auto-test/components/README.md')
          .and_return instance_double File::Stat, file?: true, directory?: false
        '/home/auto-test/components/cart'.then do |entry|
          allow(File).to receive(:stat).with(entry).and_return instance_double File::Stat, file?: false,
                                                                                           directory?: true
          allow(Dir).to receive(:entries).with(entry).and_return %w[. .. CartItem.vue CartItemDetail.vue]
          %w[CartItem.vue CartItemDetail.vue].each do |vue|
            path = "#{entry}/#{vue}"
            allow(File).to receive(:stat).with(path).and_return instance_double File::Stat, file?: true,
                                                                                            directory?: false
            allow(cli).to receive(:convert_lines).with(path).and_return false
          end
        end
      end

      it 'should check whether can convert recursively' do
        cli.swap_file_deep dir

        expect(cli).not_to have_received(:convert_lines).with '/home/auto-test/components/README.md'
        expect(cli).to have_received(:convert_lines).with '/home/auto-test/components/Cart.vue'
        expect(cli).to have_received(:convert_lines).with '/home/auto-test/components/cart/CartItem.vue'
        expect(cli).to have_received(:convert_lines).with '/home/auto-test/components/cart/CartItemDetail.vue'
      end
    end

    context 'when directories have multiple nested directories' do
      let(:dir) { '/home/auto-test/components' }

      before do
        '/home/auto-test/components'.then do |entry|
          allow(Dir).to receive(:entries).with(entry).and_return %w[. .. cart]
        end
        '/home/auto-test/components/cart'.then do |entry|
          allow(File).to receive(:stat).with(entry).and_return instance_double File::Stat, file?: false,
                                                                                           directory?: true
          allow(Dir).to receive(:entries).with(entry).and_return %w[. .. internals]
        end
        '/home/auto-test/components/cart/internals'.then do |entry|
          allow(File).to receive(:stat).with(entry).and_return instance_double File::Stat, file?: false,
                                                                                           directory?: true
          allow(Dir).to receive(:entries).with(entry).and_return %w[. .. CartItemPrice.vue]
        end
        '/home/auto-test/components/cart/internals/CartItemPrice.vue'.then do |entry|
          allow(File).to receive(:stat).with(entry).and_return instance_double File::Stat, file?: true,
                                                                                           directory?: false
          allow(cli).to receive(:convert_lines).with(entry).and_return false
        end
      end

      it 'should traverse and convert' do
        cli.swap_file_deep dir

        expect(cli).to have_received(:convert_lines).with '/home/auto-test/components/cart/internals/CartItemPrice.vue'
      end
    end
  end
  # rubocop:enable Metric/BlockLength
end
