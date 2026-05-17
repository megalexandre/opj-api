# frozen_string_literal: true

class ProjectStatusComment < ApplicationRecord
  belongs_to :project_status
  belongs_to :creator, class_name: 'User', foreign_key: :created_by, optional: true

  validates :body, presence: true
end
