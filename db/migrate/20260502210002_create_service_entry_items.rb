# frozen_string_literal: true

class CreateServiceEntryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :service_entry_items, id: :uuid do |t|
      t.references :service, type: :uuid, null: false, foreign_key: true
      t.string     :connection_type,              null: false
      t.string     :classification,               null: false
      t.integer    :quantity,                     null: false
      t.string     :circuit_breaker,              null: false

      t.timestamps
    end
  end
end
