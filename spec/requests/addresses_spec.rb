# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Addresses', type: :request do
  include_context 'with auth token'

  path '/addresses' do
    get 'Lista todos os endereços' do
      tags 'Addresses'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de endereços' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Address' }
        run_test!
      end
    end

    post 'Cria um endereço' do
      tags 'Addresses'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :address, in: :body, schema: {
        type: :object,
        properties: {
          link: { type: :string },
          place: { type: :string },
          cep: { type: :string },
          number: { type: :string },
          address: { type: :string },
          complement: { type: :string },
          neighborhood: { type: :string },
          city: { type: :string },
          state: { type: :string }
        }
      }

      response '201', 'endereço criado' do
        let(:address) { { place: 'Rua das Flores', number: '10', city: 'BH', state: 'MG' } }
        schema '$ref' => '#/components/schemas/Address'
        run_test!
      end
    end
  end

  path '/addresses/paginate' do
    get 'Lista endereços paginados' do
      tags 'Addresses'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'

      response '200', 'página de endereços' do
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/Address' } }
            }
          }
        ]
        run_test!
      end
    end
  end

  path '/addresses/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca um endereço' do
      tags 'Addresses'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'endereço encontrado' do
        let(:id) { create(:address).id }
        schema '$ref' => '#/components/schemas/Address'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um endereço' do
      tags 'Addresses'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :address, in: :body, schema: {
        type: :object,
        properties: {
          link: { type: :string },
          place: { type: :string },
          cep: { type: :string },
          number: { type: :string },
          address: { type: :string },
          complement: { type: :string },
          neighborhood: { type: :string },
          city: { type: :string },
          state: { type: :string }
        }
      }

      response '200', 'endereço atualizado' do
        let(:id)      { create(:address).id }
        let(:address) { { city: 'Rio de Janeiro', state: 'RJ' } }
        schema '$ref' => '#/components/schemas/Address'
        run_test!
      end
    end

    delete 'Remove um endereço' do
      tags 'Addresses'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:address).id }
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
