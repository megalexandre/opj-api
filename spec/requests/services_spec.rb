# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Services', type: :request do
  include_context 'with auth token'

  path '/services' do
    get 'Lista todos os serviços' do
      tags 'Services'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de serviços' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Service' }
        run_test!
      end
    end

    post 'Cria um serviço' do
      tags 'Services'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :service, in: :body, schema: {
        type: :object,
        properties: {
          service_type: { type: :string },
          customer_id: { type: :string, format: :uuid },
          concessionaire_id: { type: :string, format: :uuid },
          opening_date: { type: :string, format: :date },
          amount: { type: :string },
          discount_coupon_percentage: { type: :integer },
          observations: { type: :string },
          supply_voltage: { type: :string },
          generating_consumer_unit: { type: :string },
          pole_distance_over_30m: { type: :boolean },
          construction_address_id: { type: :string, format: :uuid },
          generating_address_id: { type: :string, format: :uuid },
          apportionments_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                consumer_unit: { type: :string },
                address: { type: :string },
                classification: { type: :string },
                percentage: { type: :integer }
              }
            }
          },
          service_entry_items_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                connection_type: { type: :string },
                classification: { type: :string },
                quantity: { type: :integer },
                circuit_breaker: { type: :string }
              }
            }
          }
        },
        required: %w[service_type customer_id concessionaire_id opening_date amount]
      }

      response '201', 'serviço criado' do
        let(:service) do
          {
            service_type: 'Ligação Nova',
            customer_id: create(:customer).id,
            concessionaire_id: create(:concessionaire).id,
            opening_date: Date.today.iso8601,
            amount: '150.00'
          }
        end
        schema '$ref' => '#/components/schemas/Service'
        run_test!
      end

      response '422', 'dados inválidos' do
        let(:service) { { service_type: 'Ligação Nova' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/services/paginate' do
    get 'Lista serviços paginados' do
      tags 'Services'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'

      response '200', 'página de serviços' do
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/Service' } }
            }
          }
        ]
        run_test!
      end
    end
  end

  path '/services/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca um serviço' do
      tags 'Services'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'serviço encontrado' do
        let(:id) { create(:service).id }
        schema '$ref' => '#/components/schemas/Service'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um serviço' do
      tags 'Services'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :service, in: :body, schema: {
        type: :object,
        properties: {
          service_type: { type: :string },
          observations: { type: :string },
          amount: { type: :string }
        }
      }

      response '200', 'serviço atualizado' do
        let(:id)      { create(:service).id }
        let(:service) { { observations: 'Atualizado', amount: '200.00' } }
        schema '$ref' => '#/components/schemas/Service'
        run_test!
      end
    end

    delete 'Remove um serviço' do
      tags 'Services'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:service).id }
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
