# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'default scope' do
    it 'excludes soft-deleted projects' do
      active = create(:project)
      deleted = create(:project, deleted_at: Time.current)

      expect(Project.all).to include(active)
      expect(Project.all).not_to include(deleted)
    end
  end

  describe '#visible_to?' do
    let(:owner)      { create(:user) }
    let(:integrator) { create(:user) }
    let(:other)      { create(:user) }
    let(:admin)      { create(:user, profile: 'admin') }
    let(:project) do
      Current.user = owner
      create(:project, integrator: integrator.id)
    end

    after { Current.user = nil }

    it 'is visible to admins' do
      expect(project.visible_to?(admin)).to be true
    end

    it 'is visible to the owner' do
      expect(project.visible_to?(owner)).to be true
    end

    it 'is visible to the assigned integrator' do
      expect(project.visible_to?(integrator)).to be true
    end

    it 'is not visible to unrelated users' do
      expect(project.visible_to?(other)).to be false
    end
  end

  describe '.visible_to' do
    it 'returns every project for admins' do
      create(:project)
      admin = create(:user, profile: 'admin')

      expect(Project.visible_to(admin)).to match_array(Project.all)
    end

    it 'returns only owned or integrated projects for regular users' do
      owner = create(:user)
      Current.user = owner
      owned = create(:project)
      Current.user = nil

      other_owner = create(:user)
      Current.user = other_owner
      create(:project)
      Current.user = nil

      expect(Project.visible_to(owner)).to contain_exactly(owned)
    end
  end
end
