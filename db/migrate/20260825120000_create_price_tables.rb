# frozen_string_literal: true

class CreatePriceTables < ActiveRecord::Migration[8.1]
  def change
    create_table :price_tables, id: :uuid do |t|
      t.string :kind, null: false
      t.string :name, null: false
      t.jsonb :values, null: false, default: []
      t.uuid :created_by
      t.uuid :updated_by
      t.timestamps
    end

    add_index :price_tables, :kind
  end
end
