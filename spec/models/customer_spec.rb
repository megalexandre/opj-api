# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:address).optional }
  end

  describe 'uniqueness' do
    subject { build(:customer) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:tax_id).ignoring_case_sensitivity }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:address) }
  end

  describe 'dependent destroy' do
    it 'destroys the associated address when destroyed' do
      customer = create(:customer)
      address = customer.address

      expect { customer.destroy }.to change(Address, :count).by(-1)
      expect(Address.exists?(address.id)).to be false
    end
  end

  describe 'creating with nested address' do
    it 'creates a customer with a new address in one step' do
      expect do
        Customer.create!(
          name: 'João Silva',
          email: 'joao@exemplo.com',
          tax_id: '12345678901',
          address_attributes: {
            place: 'Av. Paulista',
            number: '1000',
            city: 'São Paulo',
            state: 'SP',
            cep: '01310-100',
            neighborhood: 'Bela Vista'
          }
        )
      end.to change(Customer, :count).by(1).and change(Address, :count).by(1)
    end
  end
end
