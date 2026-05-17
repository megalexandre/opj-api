# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    place       { 'Rua das Flores' }
    number      { '123' }
    neighborhood { 'Centro' }
    city        { 'São Paulo' }
    state       { 'SP' }
    cep         { '01310-100' }
  end
end
