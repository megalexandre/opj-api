# frozen_string_literal: true

class MakeNameNotNullOnConcessionaires < ActiveRecord::Migration[8.1]
  def change
    change_column_null :concessionaires, :name, false
  end
end
