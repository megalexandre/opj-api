# frozen_string_literal: true

class AddAuditColumnsToTables < ActiveRecord::Migration[8.1]
  TABLES = %i[addresses customers concessionaires projects uploads].freeze

  def change
    TABLES.each do |table|
      add_column table, :created_by, :uuid
      add_column table, :updated_by, :uuid
    end

    TABLES.each do |table|
      add_foreign_key table, :users, column: :created_by
      add_foreign_key table, :users, column: :updated_by
    end
  end
end
