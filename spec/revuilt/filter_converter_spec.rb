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

    context 'a line has simple mustache expression' do
      let(:lines) { ['<ul v-for="item in items" :key="item.id"> {{ item.name }} {{ item.price | date }} </ul>'] }

      it 'should be converted only Vue filter syntax' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq [
          '<ul v-for="item in items" :key="item.id"> {{ item.name }} {{ $date(item.price) }} </ul>'
        ]
      end
    end

    context 'when there are some lines with Vue filter syntax' do
      let(:lines) { ['{{ payedAt | date }}', '{{ item.price | price }}'] }

      it 'should replace filter syntax with function call' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq ['{{ $date(payedAt) }}', '{{ item.price | price }}']
      end
    end

    context 'when DOM element wraps Vue filter syntax' do
      let(:lines) { ['  <p><span>{{ entryAt | date }}</span></P'] }

      it 'should convert it to function calling' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq ['  <p><span>{{ $date(entryAt) }}</span></P']
      end
    end

    context 'when a line includes function call before Vue filter calling' do
      let(:lines) { ['<p>', '{{ setDefaultDate(cart.item.registeredAt) | date }}', '</p>'] }

      it 'should replace filter syntax with function call' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq ['<p>', '{{ $date(setDefaultDate(cart.item.registeredAt)) }}', '</p>']
      end
    end

    context 'when a line has some types of Vue filter callings' do
      let(:lines) { ['{{ payedAt | date }} {{ item.price | price }}'] }

      it 'should convert only `date` filter' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq(
          ['{{ $date(payedAt) }} {{ item.price | price }}']
        )
      end
    end

    context 'when a line has multiple replacement targets' do
      let(:lines) { ['{{ entryStartedAt | date }}~{{ entryEndedAt | date }}: {{ item.price | price }}'] }

      it 'should convert matched filter all to function callings' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq [
          '{{ $date(entryStartedAt) }}~{{ $date(entryEndedAt) }}: {{ item.price | price }}'
        ]
      end
    end

    # rubocop:disable Style/LineLength
    context 'when Vue filter arguments has some conditions' do
      let(:lines) { ['<template v-if="shouldShow">{{ transaction.billedDate ? transaction.billedDate : getDefaultDate() | date }}</template>'] }

      it 'should wrap those with function calling' do
        results = converter.convert!

        expect(results.converted).to eq true
        expect(results.lines).to eq [
          '<template v-if="shouldShow">{{ $date(transaction.billedDate ? transaction.billedDate : getDefaultDate()) }}</template>'
        ]
      end
    end
    # rubocop:enable Style/LineLength
  end

  describe '#to_function_call' do
    [
      {
        description: 'single spaces',
        condition: '{{ detail.startedAt | date }}',
        expectation: '{{ $date(detail.startedAt) }}'
      },
      {
        description: 'no spaces',
        condition: '{{detail.startedAt|date}}',
        expectation: '{{ $date(detail.startedAt) }}'
      },
      {
        description: 'multiple randomized spaces',
        condition: '{{  detail.startedAt   | date  }}',
        expectation: '{{ $date(detail.startedAt) }}'
      },
      {
        description: 'function calling',
        condition: '{{ setDefaultDate(detail.startedAt) | date }}',
        expectation: '{{ $date(setDefaultDate(detail.startedAt)) }}'
      },
      {
        description: 'simple mustache syntax',
        condition: '{{ item.price }}',
        expectation: '{{ item.price }}'
      }
    ].each do |spec_case|
      context "when filter syntax in template has #{spec_case[:description]}" do
        let(:subject) { spec_case[:condition] }

        it "should be #{spec_case[:expectation]}" do
          result = converter.to_function_call_style(spec_case[:condition], function_symbol)

          expect(result).to eq(spec_case[:expectation])
        end
      end
    end
  end
end
