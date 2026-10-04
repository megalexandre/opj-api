# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      relation.visible_to(user)
    end
  end
end
