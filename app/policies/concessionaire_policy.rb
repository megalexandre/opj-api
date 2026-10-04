# frozen_string_literal: true

class ConcessionairePolicy < ApplicationPolicy
  # Reference data: everyone can read every concessionaire.
  class Scope < ApplicationPolicy::Scope
    def resolve
      relation
    end
  end
end
