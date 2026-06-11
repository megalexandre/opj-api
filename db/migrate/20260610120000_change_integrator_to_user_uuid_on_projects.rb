# frozen_string_literal: true

class ChangeIntegratorToUserUuidOnProjects < ActiveRecord::Migration[8.1]
  def up
    add_column :projects, :integrator_uuid, :uuid

    # Best-effort: old column held free-text names; keep rows whose name matches a user
    execute <<~SQL
      UPDATE projects
      SET integrator_uuid = users.id
      FROM users
      WHERE users.name = projects.integrator
    SQL

    remove_column :projects, :integrator
    rename_column :projects, :integrator_uuid, :integrator
    add_foreign_key :projects, :users, column: :integrator
    add_index :projects, :integrator
  end

  def down
    remove_index :projects, :integrator
    remove_foreign_key :projects, :users, column: :integrator
    change_column :projects, :integrator, :string
  end
end
