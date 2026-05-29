class Ledger < ApplicationRecord
  include Auditable

  belongs_to :project, optional: true
  belongs_to :service, optional: true

  monetize :amount_cents

  validates :amount_cents, presence: true
end
