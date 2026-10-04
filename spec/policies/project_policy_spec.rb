# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectPolicy do
  let(:owner)      { create(:user) }
  let(:integrator) { create(:user) }
  let(:other)      { create(:user) }
  let(:admin)      { create(:user, profile: 'admin') }
  let(:project) do
    Current.user = owner
    create(:project, integrator: integrator.id)
  end

  after { Current.user = nil }

  describe '#visible?' do
    it 'is visible to admins, the owner and the assigned integrator' do
      [admin, owner, integrator].each do |user|
        expect(described_class.new(user, project)).to be_visible
      end
    end

    it 'is not visible to unrelated users' do
      expect(described_class.new(other, project)).not_to be_visible
    end
  end

  describe '#allowed?' do
    it 'lets admins do everything' do
      %i[index show create update destroy inactivate].each do |action|
        expect(described_class.new(admin, project).allowed?(action)).to be true
      end
    end

    it 'lets integrators read and create but not change projects' do
      policy = described_class.new(integrator, project)
      expect(%i[index show create].map { policy.allowed?(_1) }).to all(be true)
      expect(%i[update destroy inactivate].map { policy.allowed?(_1) }).to all(be false)
    end
  end
end
