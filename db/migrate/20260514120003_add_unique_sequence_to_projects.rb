# frozen_string_literal: true

class AddUniqueSequenceToProjects < ActiveRecord::Migration[8.1]
  def change
    remove_index :projects, :sequence

    add_index :projects, :sequence,
              unique: true,
              where: 'subsequence IS NULL',
              name: 'index_projects_on_sequence_without_subsequence'

    add_index :projects, %i[sequence subsequence],
              unique: true,
              where: 'subsequence IS NOT NULL',
              name: 'index_projects_on_sequence_with_subsequence'
  end
end
