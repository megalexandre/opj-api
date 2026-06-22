# frozen_string_literal: true

class Customer < ApplicationRecord
  include Auditable

  belongs_to :address
  accepts_nested_attributes_for :address

  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :tax_id, uniqueness: true, allow_blank: true

  after_destroy :destroy_address

  private

  def destroy_address
    Address.find_by(id: address_id)&.destroy
  end
end
