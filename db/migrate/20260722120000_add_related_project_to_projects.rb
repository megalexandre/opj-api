# frozen_string_literal: true

class AddRelatedProjectToProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :projects, :related_project, type: :uuid, null: true, foreign_key: { to_table: :projects },
                                                 index: true
  end
end
