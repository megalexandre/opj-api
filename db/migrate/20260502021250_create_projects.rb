# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.references :client, type: :uuid, null: false, foreign_key: { to_table: :customers }
      t.references :address, type: :uuid, null: true, foreign_key: true
      t.string :utility_company, null: false
      t.string :utility_protocol, null: false
      t.string :customer_class, null: false
      t.string :integrator, null: false
      t.string :modality, null: false
      t.string :framework, null: false
      t.string :status
      t.decimal :amount
      t.string :dc_protection
      t.float :system_power
      t.string :unit_control, null: false
      t.string :description, limit: 1024
      t.string :project_type, null: false
      t.boolean :fast_track, null: false, default: false
      t.st_point :coordinates, geographic: true
      t.string :services_names, array: true

      t.timestamps
    end
  end
end
