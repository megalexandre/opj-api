# frozen_string_literal: true

class CreateConcessionaires < ActiveRecord::Migration[8.1]
  def change
    create_table :concessionaires, id: :uuid do |t|
      t.string :name
      t.string :acronym
      t.string :code
      t.string :region
      t.string :phone
      t.string :email
      t.boolean :active

      t.timestamps
    end
  end
end
