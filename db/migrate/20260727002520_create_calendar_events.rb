# frozen_string_literal: true

class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events, id: :uuid do |t|
      t.date       :date, null: false
      t.jsonb      :content, null: false, default: {}
      t.references :project, type: :uuid, null: true, foreign_key: true
      t.uuid       :created_by
      t.uuid       :updated_by

      t.timestamps
    end

    add_index :calendar_events, :date
  end
end
