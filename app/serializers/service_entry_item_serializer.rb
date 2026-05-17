# frozen_string_literal: true

class ServiceEntryItemSerializer
  def initialize(service_entry_item)
    @item = service_entry_item
  end

  def as_json(*)
    {
      id: @item.id,
      service_id: @item.service_id,
      connection_type: @item.connection_type,
      classification: @item.classification,
      quantity: @item.quantity,
      circuit_breaker: @item.circuit_breaker,
      created_at: @item.created_at,
      updated_at: @item.updated_at
    }
  end
end
