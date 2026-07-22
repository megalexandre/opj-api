# frozen_string_literal: true

class MakeAddressIdOptionalOnCustomers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :customers, :address_id, true
  end
end
