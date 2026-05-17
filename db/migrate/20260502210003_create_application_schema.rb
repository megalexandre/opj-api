# frozen_string_literal: true

class CreateApplicationSchema < ActiveRecord::Migration[8.1]
  def up
    # Cria o schema se ele não existir
    execute 'CREATE SCHEMA IF NOT EXISTS api_data;'
  end

  def down; end
end
