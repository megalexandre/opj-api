# frozen_string_literal: true

class MoveSequenceToProjects < ActiveRecord::Migration[8.1]
  def change
    remove_index :project_statuses, %i[project_id sequence]
    remove_column :project_statuses, :sequence, :integer
    remove_column :project_statuses, :subsequence, :string

    add_column :projects, :sequence, :integer
    add_column :projects, :subsequence, :string
    add_index :projects, :sequence, unique: true
  end
end
