# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:owner)      { create(:user) }
  let(:integrator) { create(:user) }
  let(:other)      { create(:user) }
  let(:admin)      { create(:user, profile: 'admin') }
  let(:service) do
    Current.user = owner
    create(:service, integrator: integrator.id)
  end

  after { Current.user = nil }

  describe '#visible?' do
    it 'is visible to admins, the owner and the assigned integrator' do
      [admin, owner, integrator].each do |user|
        expect(described_class.new(user, service)).to be_visible
      end
    end

    it 'is not visible to unrelated users' do
      expect(described_class.new(other, service)).not_to be_visible
    end
  end

  describe '#allowed?' do
    it 'lets admins do everything' do
      %i[index show create update destroy].each do |action|
        expect(described_class.new(admin, service).allowed?(action)).to be true
      end
    end

    it 'lets the owner do everything' do
      policy = described_class.new(owner, service)
      expect(%i[index show create update destroy].map { policy.allowed?(_1) }).to all(be true)
    end

    it 'lets the assigned integrator read and create but not change the service' do
      policy = described_class.new(integrator, service)
      expect(%i[index show create].map { policy.allowed?(_1) }).to all(be true)
      expect(%i[update destroy].map { policy.allowed?(_1) }).to all(be false)
    end
  end
end
