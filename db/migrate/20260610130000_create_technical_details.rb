# frozen_string_literal: true

class CreateTechnicalDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :technical_details, id: :uuid do |t|
      t.references :project, type: :uuid, null: false, foreign_key: true
      t.date    :opening_date
      t.string  :supply_voltage
      t.boolean :new_project,       null: false, default: false
      t.boolean :zero_grid_control, null: false, default: false
      t.string  :modules,              array: true, default: []
      t.string  :inverters,            array: true, default: []
      t.string  :entry_standard_items, array: true, default: []
      t.string  :credit_divisions,     array: true, default: []
      t.uuid    :created_by
      t.uuid    :updated_by

      t.timestamps
    end
  end
end
