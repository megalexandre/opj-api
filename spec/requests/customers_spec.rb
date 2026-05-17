# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Customers', type: :request do
  include_context 'with auth token'

  path '/customers' do
    get 'Lista todos os clientes' do
      tags 'Customers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de clientes' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Customer' }
        run_test!
      end
    end

    post 'Cria um cliente' do
      tags 'Customers'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          tax_id: { type: :string },
          phone: { type: :string },
          address_id: { type: :string, format: :uuid, description: 'Vincular endereço existente' },
          address_attributes: {
            type: :object,
            description: 'Criar endereço junto com o cliente',
            properties: {
              place: { type: :string }, cep: { type: :string }, number: { type: :string },
              city: { type: :string }, state: { type: :string }
            }
          }
        }
      }

      response '201', 'cliente criado' do
        let(:customer) do
          address = create(:address)
          { name: 'João', email: 'joao@test.com', phone: '31999999999', address_id: address.id }
        end
        schema '$ref' => '#/components/schemas/Customer'
        run_test!
      end

      response '422', 'e-mail ou CPF/CNPJ já cadastrado' do
        before { create(:customer, email: 'duplicado@test.com') }
        let(:customer) { { name: 'Outro', email: 'duplicado@test.com' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/customers/paginate' do
    get 'Lista clientes paginados' do
      tags 'Customers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'

      response '200', 'página de clientes' do
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/Customer' } }
            }
          }
        ]
        run_test!
      end
    end
  end

  path '/customers/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca um cliente' do
      tags 'Customers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'cliente encontrado' do
        let(:id) { create(:customer).id }
        schema '$ref' => '#/components/schemas/Customer'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um cliente' do
      tags 'Customers'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          tax_id: { type: :string },
          phone: { type: :string }
        }
      }

      response '200', 'cliente atualizado' do
        let(:id)       { create(:customer).id }
        let(:customer) { { name: 'Nome Atualizado', phone: '11988887777' } }
        schema '$ref' => '#/components/schemas/Customer'
        run_test!
      end
    end

    delete 'Remove um cliente' do
      tags 'Customers'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:customer).id }
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
