# frozen_string_literal: true

class PriceTableSerializer
  def initialize(price_table)
    @price_table = price_table
  end

  def as_json(*)
    {
      id: @price_table.id,
      kind: @price_table.kind,
      name: @price_table.name,
      values: @price_table.values,
      created_at: @price_table.created_at,
      updated_at: @price_table.updated_at,
      created_by: @price_table.created_by,
      updated_by: @price_table.updated_by
    }
  end
end
