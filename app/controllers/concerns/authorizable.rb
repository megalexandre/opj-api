# frozen_string_literal: true

# Controller helpers backed by app/policies.
#
#   policy_scope(Ledger.all)        # records the current user can see
#   authorize!(@ledger)             # 404 if outside scope, 403 if action denied
#   authorize!(Ledger, :create)     # collection-level check
module Authorizable
  extend ActiveSupport::Concern

  class ForbiddenError < StandardError
  end

  # Controller actions that map to one of the policy actions.
  ACTION_ALIASES = {
    paginate: :index,
    new: :create,
    register: :create,
    edit: :update,
    reset_password: :update,
    download: :show,
    destroy_by_item: :destroy
  }.freeze

  private

  def policy_scope(relation)
    ApplicationPolicy::Scope.for(current_user, relation).resolve
  end

  def policy_for(record)
    ApplicationPolicy.for(current_user, record)
  end

  def authorize!(record, action = policy_action)
    policy = policy_for(record)
    raise ActiveRecord::RecordNotFound, "Couldn't find #{record.class.name}" unless policy.visible?
    raise ForbiddenError, 'Forbidden' unless policy.allowed?(action)

    record
  end

  # Records that point at a project (ledgers, calendar events, uploads) may
  # only reference projects the user can see.
  def authorize_project_reference!(project_id)
    authorize!(Project.find(project_id), :show) if project_id.present?
  end

  def policy_action
    ACTION_ALIASES.fetch(action_name.to_sym, action_name.to_sym)
  end
end
