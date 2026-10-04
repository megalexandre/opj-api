# frozen_string_literal: true

class RenameUserProfileToIntegrator < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET profile = 'integrator' WHERE profile = 'user'"
    change_column_default :users, :profile, from: 'user', to: 'integrator'
  end

  def down
    execute "UPDATE users SET profile = 'user' WHERE profile = 'integrator'"
    change_column_default :users, :profile, from: 'integrator', to: 'user'
  end
end
