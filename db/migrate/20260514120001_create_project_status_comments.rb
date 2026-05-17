# frozen_string_literal: true

class CreateProjectStatusComments < ActiveRecord::Migration[8.1]
  def change
    create_table :project_status_comments, id: :uuid do |t|
      t.references :project_status, type: :uuid, null: false, foreign_key: true
      t.text :body, null: false
      t.uuid :created_by
      t.timestamps
    end

    add_foreign_key :project_status_comments, :users, column: :created_by
  end
end
