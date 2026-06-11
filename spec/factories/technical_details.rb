# frozen_string_literal: true

FactoryBot.define do
  factory :technical_detail do
    association :project
    opening_date         { Date.new(2026, 6, 1) }
    supply_voltage       { '220V' }
    new_project          { true }
    zero_grid_control    { false }
    modules              { ['Canadian 550W x12'] }
    inverters            { ['Growatt 5kW'] }
    entry_standard_items { ['Disjuntor 63A'] }
    credit_divisions     { ['UC-123: 60%'] }
  end
end
