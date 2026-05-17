# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :uploads, id: :uuid do |t|
      t.uuid   :item_id,  null: false
      t.string :filename, null: false
      t.string :s3_url,   null: false
      t.string :s3_key,   null: false
      t.bigint :size,     null: false, default: 0

      t.timestamps
    end

    add_index :uploads, :item_id
  end
end
