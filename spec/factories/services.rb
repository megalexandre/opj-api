# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    association :customer
    association :concessionaire
    service_type             { 'Ligação Nova' }
    opening_date             { Date.today }
    amount                   { '150.00' }
    discount_coupon_percentage { nil }
    observations             { nil }
    supply_voltage           { nil }
    coordinates              { nil }
    generating_consumer_unit { nil }
    pole_distance_over_30m   { false }
    construction_address_id  { nil }
    generating_address_id    { nil }
  end
end
