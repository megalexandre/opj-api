# frozen_string_literal: true

class AddRelatedProjectToProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :projects, :related_project, 
      type: :uuid, null: true, index: true,
      foreign_key: { to_table: :projects }
  end
end
