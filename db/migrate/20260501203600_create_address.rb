# frozen_string_literal: true

class CreateAddress < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :link
      t.string :place
      t.string :cep
      t.string :number
      t.string :address
      t.string :complement
      t.string :neighborhood
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
