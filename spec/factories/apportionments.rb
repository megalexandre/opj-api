# frozen_string_literal: true

FactoryBot.define do
  factory :apportionment do
    association :service
    consumer_unit  { 'UC-001' }
    address        { 'Rua Teste, 100' }
    classification { 'B1' }
    percentage     { 100 }
  end
end
