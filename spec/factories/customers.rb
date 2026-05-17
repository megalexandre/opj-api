# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:name)   { |n| "Cliente #{n}" }
    sequence(:email)  { |n| "cliente#{n}@exemplo.com" }
    sequence(:tax_id) { |n| "#{n.to_s.rjust(11, '0')}" }
    phone             { '11999999999' }
    association :address
  end
end
