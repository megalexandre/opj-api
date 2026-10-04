# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LedgerPolicy do
  let(:admin)      { create(:user, profile: 'admin') }
  let(:integrator) { create(:user) }
  let(:other)      { create(:user) }

  # Project created by the admin and assigned to the integrator.
  let(:assigned_project) do
    Current.user = admin
    create(:project, integrator: integrator.id)
  end
  let(:other_project) do
    Current.user = admin
    create(:project)
  end
  let!(:admin_ledger) do
    Current.user = admin
    create(:ledger, project: assigned_project)
  end
  let!(:unrelated_ledger) do
    Current.user = admin
    create(:ledger, project: other_project)
  end
  let!(:own_ledger) do
    Current.user = integrator
    create(:ledger, project: nil)
  end

  after { Current.user = nil }

  describe 'Scope' do
    def resolve(user)
      ApplicationPolicy::Scope.for(user, Ledger.all).resolve
    end

    it 'gives admins every ledger' do
      expect(resolve(admin)).to contain_exactly(admin_ledger, unrelated_ledger, own_ledger)
    end

    it 'gives integrators the ledgers of assigned projects plus their own' do
      expect(resolve(integrator)).to contain_exactly(admin_ledger, own_ledger)
    end

    it 'gives unrelated users nothing' do
      expect(resolve(other)).to be_empty
    end
  end

  describe '#allowed?' do
    it 'lets integrators read but not change ledgers created by others' do
      policy = described_class.new(integrator, admin_ledger)
      expect(policy.allowed?(:show)).to be true
      expect(policy.allowed?(:update)).to be false
      expect(policy.allowed?(:destroy)).to be false
    end

    it 'lets integrators change their own ledgers' do
      policy = described_class.new(integrator, own_ledger)
      expect(policy.allowed?(:update)).to be true
      expect(policy.allowed?(:destroy)).to be true
    end
  end
end
