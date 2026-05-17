# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Concessionaires', type: :request do
  include_context 'with auth token'

  path '/concessionaires' do
    get 'Lista todas as concessionárias' do
      tags 'Concessionaires'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de concessionárias' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Concessionaire' }
        run_test!
      end
    end

    post 'Cria uma concessionária' do
      tags 'Concessionaires'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :concessionaire, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          acronym: { type: :string },
          code: { type: :string },
          region: { type: :string },
          phone: { type: :string },
          email: { type: :string },
          active: { type: :boolean }
        }
      }

      response '201', 'concessionária criada' do
        let(:concessionaire) { { name: 'CEMIG', acronym: 'CMG', code: '001', region: 'Sudeste', active: true } }
        schema '$ref' => '#/components/schemas/Concessionaire'
        run_test!
      end
    end
  end

  path '/concessionaires/paginate' do
    get 'Lista concessionárias paginadas' do
      tags 'Concessionaires'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'

      response '200', 'página de concessionárias' do
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/Concessionaire' } }
            }
          }
        ]
        run_test!
      end
    end
  end

  path '/concessionaires/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca uma concessionária' do
      tags 'Concessionaires'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'concessionária encontrada' do
        let(:id) { create(:concessionaire).id }
        schema '$ref' => '#/components/schemas/Concessionaire'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza uma concessionária' do
      tags 'Concessionaires'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :concessionaire, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          acronym: { type: :string },
          code: { type: :string },
          region: { type: :string },
          phone: { type: :string },
          email: { type: :string },
          active: { type: :boolean }
        }
      }

      response '200', 'concessionária atualizada' do
        let(:id)             { create(:concessionaire).id }
        let(:concessionaire) { { active: false } }
        schema '$ref' => '#/components/schemas/Concessionaire'
        run_test!
      end
    end

    delete 'Remove uma concessionária' do
      tags 'Concessionaires'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removida com sucesso' do
        let(:id) { create(:concessionaire).id }
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
