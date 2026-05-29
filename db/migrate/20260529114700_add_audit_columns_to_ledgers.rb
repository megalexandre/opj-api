# frozen_string_literal: true

class AddAuditColumnsToLedgers < ActiveRecord::Migration[8.1]
  def change
    add_column :ledgers, :created_by, :uuid
    add_column :ledgers, :updated_by, :uuid

    add_foreign_key :ledgers, :users, column: :created_by
    add_foreign_key :ledgers, :users, column: :updated_by
  end
end
