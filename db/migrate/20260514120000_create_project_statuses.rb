# frozen_string_literal: true

class CreateProjectStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :project_statuses, id: :uuid do |t|
      t.references :project, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :sequence, null: false
      t.string :subsequence
      t.uuid :created_by
      t.timestamps
    end

    add_index :project_statuses, %i[project_id sequence], unique: true
    add_foreign_key :project_statuses, :users, column: :created_by
  end
end
