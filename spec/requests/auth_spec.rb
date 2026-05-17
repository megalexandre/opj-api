# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth', type: :request do
  path '/auth/register' do
    post 'Registra um novo usuário' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      security []

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        required: %w[name email password],
        properties: {
          name: { type: :string },
          email: { type: :string },
          profile: { type: :string },
          password: { type: :string }
        }
      }

      response '201', 'usuário criado e token retornado' do
        let(:credentials) { { name: 'Test User', email: 'test@example.com', profile: 'user', password: 'password123' } }
        schema '$ref' => '#/components/schemas/AuthToken'
        run_test!
      end

      response '422', 'dados inválidos' do
        let(:credentials) { { name: '', email: 'invalid', password: '' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/auth/login' do
    post 'Autentica um usuário' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      security []

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        required: %w[email password],
        properties: {
          email: { type: :string },
          password: { type: :string }
        }
      }

      response '200', 'autenticado com sucesso' do
        let(:credentials) do
          create(:user, email: 'login@example.com', password: 'password123')
          { email: 'login@example.com', password: 'password123' }
        end
        schema '$ref' => '#/components/schemas/AuthToken'
        run_test!
      end

      response '401', 'credenciais inválidas' do
        let(:credentials) { { email: 'wrong@example.com', password: 'wrongpassword' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/auth/me' do
    get 'Retorna o usuário autenticado' do
      tags 'Auth'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'usuário retornado' do
        include_context 'with auth token'
        schema '$ref' => '#/components/schemas/User'
        run_test!
      end

      response '401', 'token ausente ou inválido' do
        let(:Authorization) { 'Bearer invalid_token' }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
