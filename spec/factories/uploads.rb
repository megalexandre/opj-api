# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    item_id  { SecureRandom.uuid }
    filename { 'documento.pdf' }
    s3_url   { 'http://localhost:9000/deploy-board-uploads/test/documento.pdf' }
    s3_key   { 'test/documento.pdf' }
    size     { 1024 }
  end
end
