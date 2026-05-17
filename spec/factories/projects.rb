# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :client, factory: :customer
    address          { nil }
    utility_company  { 'CEMIG' }
    utility_protocol { 'PROT-001' }
    customer_class   { 'B1' }
    integrator       { 'Integrador X' }
    modality         { 'Micro' }
    framework        { 'NET' }
    status           { 'pendente' }
    amount           { '9.99' }
    dc_protection    { 'Fusivel' }
    system_power     { 1.5 }
    unit_control     { 'UC-001' }
    description      { 'Projeto teste' }
    project_type     { 'Residencial' }
    fast_track       { false }
    coordinates      { nil }
  end
end
