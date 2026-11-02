# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:concessionaire) }
    it { is_expected.to belong_to(:construction_address).class_name('Address').optional }
    it { is_expected.to belong_to(:generating_address).class_name('Address').optional }
    it { is_expected.to have_many(:apportionments).dependent(:destroy) }
    it { is_expected.to have_many(:service_entry_items).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:apportionments).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:service_entry_items).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:service_type) }
    it { is_expected.to validate_presence_of(:opening_date) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  describe 'subsequence' do
    it 'is optional' do
      expect(build(:service, subsequence: nil)).to be_valid
    end

    it 'persists the given value' do
      service = create(:service, subsequence: 'B')
      expect(service.reload.subsequence).to eq('B')
    end
  end

  describe 'auditing' do
    let(:user) { create(:user) }

    before { Current.user = user }
    after  { Current.user = nil }

    it 'sets created_by and updated_by from the current user' do
      service = create(:service)
      expect([service.created_by, service.updated_by]).to eq([user.id, user.id])
    end
  end

  describe 'destroy' do
    it 'removes its apportionments and entry items' do
      service = create(:service)
      create(:apportionment, service: service)
      create(:service_entry_item, service: service)

      expect { service.destroy! }
        .to change(Apportionment, :count).by(-1)
        .and change(ServiceEntryItem, :count).by(-1)
    end
  end
end
