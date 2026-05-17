# frozen_string_literal: true

class Address < ApplicationRecord
  include Auditable

  has_one :customer, dependent: :restrict_with_error
end
