# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :address, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :email
      t.string :tax_id
      t.string :phone

      t.timestamps
    end
    add_index :customers, :email, unique: true
    add_index :customers, :tax_id, unique: true
  end
end
