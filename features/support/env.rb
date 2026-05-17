# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require_relative '../../config/environment'
require 'cucumber/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'

ActionController::Base.allow_forgery_protection = false

DatabaseCleaner.strategy = :transaction

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

World(FactoryBot::Syntax::Methods)
