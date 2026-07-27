# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  include Auditable

  belongs_to :project, optional: true

  validates :date, presence: true
end
