# frozen_string_literal: true

class Customer < ApplicationRecord
  include Auditable

  belongs_to :address, optional: true
  accepts_nested_attributes_for :address

  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :tax_id, uniqueness: true, allow_blank: true

  after_destroy :destroy_orphaned_address

  private

  # A fresh lookup (instead of the cached `address` association) ensures
  # Address's own `restrict_with_error` check re-queries the DB and sees
  # this customer already gone, rather than the stale in-memory inverse.
  def destroy_orphaned_address
    Address.find_by(id: address_id)&.destroy
  end
end
