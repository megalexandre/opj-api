# frozen_string_literal: true

class AddSecondaryProtocolToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :secondary_protocol, :string, null: true
  end
end
