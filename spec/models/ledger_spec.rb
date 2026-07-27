# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:service).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount_cents) }
  end

  describe 'monetize' do
    it 'converts amount into amount_cents' do
      ledger = build(:ledger, amount_cents: nil)
      ledger.amount = '10.50'
      expect(ledger.amount_cents).to eq(1050)
    end
  end
end
