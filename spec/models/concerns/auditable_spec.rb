# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auditable, type: :model do
  let(:user) { create(:user) }

  before { Current.user = user }
  after  { Current.user = nil }

  describe 'on create' do
    it 'sets created_by to Current.user id' do
      project = create(:project)
      expect(project.created_by).to eq(user.id)
    end

    it 'sets updated_by to Current.user id' do
      project = create(:project)
      expect(project.updated_by).to eq(user.id)
    end
  end

  describe 'on update' do
    it 'updates updated_by to the current user' do
      project = create(:project)
      other_user = create(:user)
      Current.user = other_user
      project.update!(status: 'aprovado')
      expect(project.updated_by).to eq(other_user.id)
    end

    it 'does not change created_by' do
      project = create(:project)
      original_creator_id = user.id
      Current.user = create(:user)
      project.update!(status: 'aprovado')
      expect(project.created_by).to eq(original_creator_id)
    end
  end

  describe 'without current user' do
    before { Current.user = nil }

    it 'sets created_by to nil' do
      project = create(:project)
      expect(project.created_by).to be_nil
    end

    it 'sets updated_by to nil' do
      project = create(:project)
      expect(project.updated_by).to be_nil
    end
  end
end
