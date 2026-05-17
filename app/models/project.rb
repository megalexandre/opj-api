# frozen_string_literal: true

class Project < ApplicationRecord
  include Auditable

  belongs_to :client, class_name: 'Customer'
  belongs_to :address, optional: true

  has_many :statuses, class_name: 'ProjectStatus', dependent: :destroy
end
