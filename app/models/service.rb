# frozen_string_literal: true

class Service < ApplicationRecord
  include Auditable

  belongs_to :customer
  belongs_to :concessionaire
  belongs_to :construction_address, class_name: 'Address', optional: true
  belongs_to :generating_address,   class_name: 'Address', optional: true

  has_many :apportionments,      dependent: :destroy
  has_many :service_entry_items, dependent: :destroy

  accepts_nested_attributes_for :apportionments,      allow_destroy: true
  accepts_nested_attributes_for :service_entry_items, allow_destroy: true

  validates :service_type, :opening_date, :amount, presence: true
end
