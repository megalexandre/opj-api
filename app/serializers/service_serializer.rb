# frozen_string_literal: true

class ServiceSerializer
  def initialize(service)
    @service = service
  end

  def as_json(*)
    {
      id: @service.id,
      service_type: @service.service_type,
      customer_id: @service.customer_id,
      concessionaire_id: @service.concessionaire_id,
      opening_date: @service.opening_date,
      amount: @service.amount,
      discount_coupon_percentage: @service.discount_coupon_percentage,
      observations: @service.observations,
      supply_voltage: @service.supply_voltage,
      coordinates: serialize_coordinates(@service.coordinates),
      generating_consumer_unit: @service.generating_consumer_unit,
      pole_distance_over_30m: @service.pole_distance_over_30m,
      construction_address_id: @service.construction_address_id,
      generating_address_id: @service.generating_address_id,
      apportionments: @service.apportionments.map { ApportionmentSerializer.new(_1).as_json },
      service_entry_items: @service.service_entry_items.map { ServiceEntryItemSerializer.new(_1).as_json },
      created_at: @service.created_at,
      updated_at: @service.updated_at,
      created_by: @service.created_by,
      updated_by: @service.updated_by
    }
  end

  private

  def serialize_coordinates(point)
    return nil if point.nil?

    { latitude: point.y, longitude: point.x }
  end
end
