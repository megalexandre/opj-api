# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'PriceTables', type: :request do
  include_context 'with auth token'

  path '/price_tables' do
    get 'Lista todas as tabelas de preço' do
      tags 'PriceTables'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :kind, in: :query, type: :string, required: false, description: 'Filtra por tipo'

      response '200', 'lista de tabelas de preço' do
        schema type: :array, items: { '$ref' => '#/components/schemas/PriceTable' }
        run_test!
      end
    end

    post 'Cria uma tabela de preço' do
      tags 'PriceTables'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :price_table, in: :body, schema: {
        type: :object,
        properties: {
          kind: { type: :string, enum: PriceTable::KINDS },
          name: { type: :string },
          values: { type: :array, items: { type: :object } }
        }
      }

      response '201', 'tabela de preço criada' do
        let(:price_table) do
          {
            kind: 'fotovoltaico',
            name: 'Tabela Preço Fotovoltaico',
            values: [{ id: 'fv-1', min: 0, max: 10, valor: 600 }]
          }
        end
        schema '$ref' => '#/components/schemas/PriceTable'
        run_test!
      end
    end
  end

  path '/price_tables/paginate' do
    get 'Lista tabelas de preço paginadas' do
      tags 'PriceTables'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'

      response '200', 'página de tabelas de preço' do
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/PriceTable' } }
            }
          }
        ]
        run_test!
      end
    end
  end

  path '/price_tables/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca uma tabela de preço' do
      tags 'PriceTables'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'tabela de preço encontrada' do
        let(:id) { create(:price_table).id }
        schema '$ref' => '#/components/schemas/PriceTable'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza uma tabela de preço' do
      tags 'PriceTables'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :price_table, in: :body, schema: {
        type: :object,
        properties: {
          kind: { type: :string, enum: PriceTable::KINDS },
          name: { type: :string },
          values: { type: :array, items: { type: :object } }
        }
      }

      response '200', 'tabela de preço atualizada' do
        let(:id)          { create(:price_table).id }
        let(:price_table) { { name: 'Tabela Preço Fotovoltaico Atualizada' } }
        schema '$ref' => '#/components/schemas/PriceTable'
        run_test!
      end
    end

    delete 'Remove uma tabela de preço' do
      tags 'PriceTables'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removida com sucesso' do
        let(:id) { create(:price_table).id }
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
