# frozen_string_literal: true

class ProjectStatus < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: 'User', foreign_key: :created_by, optional: true

  has_many :comments, class_name: 'ProjectStatusComment', dependent: :destroy

  validates :name, presence: true

  after_create :sync_project_status

  private

  def sync_project_status
    project.update_column(:status, name)
  end
end
