# frozen_string_literal: true

FactoryBot.define do
  factory :concessionaire do
    name { 'MyString' }
    acronym { 'MyString' }
    code { 'MyString' }
    region { 'MyString' }
    phone { 'MyString' }
    email { 'MyString' }
    active { false }
  end
end
