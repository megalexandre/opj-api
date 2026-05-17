# frozen_string_literal: true

class Upload < ApplicationRecord
  include Auditable

  validates :item_id,  presence: true
  validates :filename, presence: true
  validates :s3_url,   presence: true
  validates :s3_key,   presence: true
  validates :size,     presence: true, numericality: { greater_than_or_equal_to: 0 }
end
