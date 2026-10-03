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
