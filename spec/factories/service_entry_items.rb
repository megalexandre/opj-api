# frozen_string_literal: true

FactoryBot.define do
  factory :service_entry_item do
    association :service
    connection_type { 'Monofásico' }
    classification  { 'Residencial' }
    quantity        { 1 }
    circuit_breaker { '20A' }
  end
end
