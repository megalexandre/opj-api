# frozen_string_literal: true

class AddIntegratorToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :integrator, :uuid
    add_foreign_key :services, :users, column: :integrator
    add_index :services, :integrator
  end
end
