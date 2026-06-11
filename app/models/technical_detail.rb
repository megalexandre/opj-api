# frozen_string_literal: true

class TechnicalDetail < ApplicationRecord
  include Auditable

  belongs_to :project
end
