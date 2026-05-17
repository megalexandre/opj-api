# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services, id: :uuid do |t|
      t.string     :service_type, null: false
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.references :concessionaire, type: :uuid, null: false, foreign_key: true
      t.date       :opening_date,               null: false
      t.decimal    :amount,                     null: false
      t.integer    :discount_coupon_percentage
      t.string     :observations
      t.string     :supply_voltage
      t.st_point   :coordinates, geographic: true
      t.string     :generating_consumer_unit
      t.boolean    :pole_distance_over_30m,     null: false, default: false
      t.references :construction_address, type: :uuid, foreign_key: { to_table: :addresses }
      t.references :generating_address,   type: :uuid, foreign_key: { to_table: :addresses }
      t.uuid       :created_by
      t.uuid       :updated_by

      t.timestamps
    end
  end
end
