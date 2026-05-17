# frozen_string_literal: true

class AddLogoToConcessionaires < ActiveRecord::Migration[8.1]
  def change
    add_column :concessionaires, :logo, :text
  end
end
