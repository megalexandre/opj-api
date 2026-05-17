# frozen_string_literal: true

class CreateApportionments < ActiveRecord::Migration[8.1]
  def change
    create_table :apportionments, id: :uuid do |t|
      t.references :service, type: :uuid, null: false, foreign_key: true
      t.string     :consumer_unit,               null: false
      t.string     :address,                     null: false
      t.string     :classification,              null: false
      t.integer    :percentage,                  null: false

      t.timestamps
    end
  end
end
