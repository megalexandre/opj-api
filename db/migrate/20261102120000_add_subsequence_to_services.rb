# frozen_string_literal: true

class AddSubsequenceToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :subsequence, :string
  end
end
