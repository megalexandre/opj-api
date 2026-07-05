# frozen_string_literal: true

class Customer < ApplicationRecord
  include Auditable

  belongs_to :address, optional: true
  accepts_nested_attributes_for :address

  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :tax_id, uniqueness: true, allow_blank: true

end
