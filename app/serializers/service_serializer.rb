# frozen_string_literal: true

class ServiceSerializer
  ATTRIBUTES = %i[
    id
    service_type
    customer_id
    concessionaire_id
    opening_date
    amount
    discount_coupon_percentage
    observations
    supply_voltage
    generating_consumer_unit
    pole_distance_over_30m
    construction_address_id
    generating_address_id
    protocol
    status
    timeline
    timeline_comments
    reference_point
    approval_status
    document_category
    reused_documents
    subsequence
    integrator
    created_at
    updated_at
    created_by
    updated_by
  ].freeze

  def initialize(service)
    @service = service
  end

  def as_json(*)
    ATTRIBUTES
      .index_with { @service.public_send(_1) }
      .merge(
        integrator_name: @service.integrator_user&.name,
        coordinates: serialize_coordinates(@service.coordinates),
        apportionments: serialize_apportionments,
        service_entry_items: serialize_service_entry_items
      )
  end

  private

  def serialize_apportionments
    @service.apportionments.map { ApportionmentSerializer.new(_1).as_json }
  end

  def serialize_service_entry_items
    @service.service_entry_items.map { ServiceEntryItemSerializer.new(_1).as_json }
  end

  def serialize_coordinates(point)
    return nil if point.nil?

    { latitude: point.y, longitude: point.x }
  end
end
