# frozen_string_literal: true

FactoryBot.define do
  factory :project_status_comment do
    association :project_status
    body { 'Comentário de teste' }
  end
end
