# frozen_string_literal: true

require 'spec_helper'

describe Spinner do
  let(:output) { StringIO.new }
  let(:spinner) { described_class.new(output: output) }

  describe '#run' do
    it 'yields the block' do
      called = false
      spinner.run { called = true }
      expect(called).to be true
    end

    it 'returns the block value' do
      result = spinner.run { 42 }
      expect(result).to eq 42
    end

    it 'stops the spinner even when the block raises' do
      expect { spinner.run { raise 'boom' } }.to raise_error(RuntimeError, 'boom')

      output_str = output.string
      expect(output_str).to include("\e[?25h")
    end
  end

  describe '#start / #stop' do
    after { spinner.stop }

    it 'starts a background thread' do
      spinner.start
      sleep 0.15

      expect(output.string).to include("\e[?25l")
    end

    it 'stops the thread and restores the cursor' do
      spinner.start
      sleep 0.15
      spinner.stop

      expect(output.string).to include("\e[?25h")
    end
  end

  describe '#stop' do
    it 'is safe to call when not started' do
      expect { spinner.stop }.not_to raise_error
    end

    it 'is safe to call twice' do
      spinner.start
      sleep 0.15
      spinner.stop
      expect { spinner.stop }.not_to raise_error
    end
  end
end
