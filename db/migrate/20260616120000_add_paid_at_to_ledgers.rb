# frozen_string_literal: true

class AddPaidAtToLedgers < ActiveRecord::Migration[8.1]
  def change
    add_column :ledgers, :paid_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
