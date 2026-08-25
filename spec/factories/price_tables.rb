# frozen_string_literal: true

FactoryBot.define do
  factory :price_table do
    kind { 'fotovoltaico' }
    name { 'Tabela Preço Fotovoltaico' }
    values do
      [
        { 'id' => 'fv-1', 'min' => 0, 'max' => 10, 'valor' => 600 }
      ]
    end
  end
end
