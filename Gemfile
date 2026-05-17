# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.2'
# Use postgresql as the database for Active Record
gem 'activerecord-postgis-adapter'
gem 'pg', '~> 1.1'
gem 'rgeo'

# gem pagination
gem 'pagy', '~> 9.3'

gem 'aws-sdk-s3', '~> 1.177' # cliente AWS S3 — usado para upload/download/delete de arquivos no MinIO

# Documentação interativa da API (Swagger UI acessível em /api-docs)
gem 'rswag-api'   # serve o arquivo OpenAPI (swagger.yaml) como endpoint JSON
gem 'rswag-ui'    # renderiza o Swagger UI no browser a partir da spec gerada

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.9'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

gem 'dotenv-rails', groups: %i[development test]

group :development do
  gem 'ruby-lsp', require: false
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false

  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rswag-specs' # helpers RSpec para escrever specs que geram o swagger.yaml
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
end
