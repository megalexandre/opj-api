# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:customer) }
  end

  describe 'restrict deletion when customer exists' do
    it 'does not destroy address that has a customer' do
      customer = create(:customer)
      address = customer.address

      address.destroy
      expect(address.errors[:base]).not_to be_empty
      expect(Address.exists?(address.id)).to be true
    end
  end
end
