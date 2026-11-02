# frozen_string_literal: true

# Role-based permission matrix: role → resource → action → rule.
#
# Rules:
#   :any — allowed on every record inside the user's policy scope
#   :own — allowed only on records the user created (created_by)
#   missing — denied
#
# Admins are allowed every action on every resource.
# Which records a user can see at all is defined by each policy's Scope.
module Permissions
  ADMIN = 'admin'
  INTEGRATOR = 'integrator'

  ROLES = [ADMIN, INTEGRATOR].freeze

  CRUD = { index: :any, show: :any, create: :any, update: :any, destroy: :any }.freeze

  MATRIX = {
    INTEGRATOR => {
      project: { index: :any, show: :any, create: :any },
      project_status: { index: :any },
      project_status_comment: { create: :any, update: :own, destroy: :own },
      technical_detail: CRUD,
      ledger: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      calendar_event: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      upload: { index: :any, show: :any, create: :any, destroy: :own },
      customer: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      address: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      service: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      concessionaire: { index: :any, show: :any, create: :any, update: :own, destroy: :own },
      price_table: CRUD
    }
  }.freeze

  def self.rule(role, resource, action)
    return :any if role == ADMIN

    MATRIX.dig(role, resource, action.to_sym)
  end
end
