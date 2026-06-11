# frozen_string_literal: true

class Project < ApplicationRecord
  include Auditable

  belongs_to :client, class_name: 'Customer'
  belongs_to :address, optional: true
  belongs_to :integrator_user, class_name: 'User', foreign_key: :integrator, optional: true,
                               inverse_of: false

  has_many :statuses, class_name: 'ProjectStatus', dependent: :destroy

  scope :visible_to, lambda { |user|
    next all if user.profile == 'main'

    where(created_by: user.id).or(where(integrator: user.id))
  }

  def visible_to?(user)
    user.profile == 'main' || created_by == user.id || integrator == user.id
  end
end
