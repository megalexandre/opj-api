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
          protocol: { type: :string },
          status: { type: :string },
          timeline: { type: :string },
          timeline_comments: { type: :string },
          reference_point: { type: :string },
          approval_status: { type: :string },
          document_category: { type: :string },
          reused_documents: { type: :string },
          subsequence: { type: :string },
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
            amount: '150.00',
            subsequence: 'A'
          }
        end
        schema '$ref' => '#/components/schemas/Service'
        run_test! do |response|
          expect(JSON.parse(response.body)['subsequence']).to eq('A')
        end
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
        let(:id) { create(:service, subsequence: 'A').id }
        schema '$ref' => '#/components/schemas/Service'
        run_test! do |response|
          expect(JSON.parse(response.body)).to include('id' => id, 'subsequence' => 'A')
        end
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
          amount: { type: :string },
          subsequence: { type: :string }
        }
      }

      response '200', 'serviço atualizado' do
        let(:id)      { create(:service).id }
        let(:service) { { observations: 'Atualizado', amount: '200.00', subsequence: 'B' } }
        schema '$ref' => '#/components/schemas/Service'
        run_test! do |response|
          expect(JSON.parse(response.body)).to include('observations' => 'Atualizado', 'subsequence' => 'B')
        end
      end

      response '422', 'dados inválidos' do
        let(:id)      { create(:service).id }
        let(:service) { { amount: nil } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete 'Remove um serviço' do
      tags 'Services'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:service).id }
        run_test! do
          expect(Service.exists?(id)).to be(false)
        end
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  describe 'nested attributes' do
    let(:headers) { { 'Authorization' => auth_token_for(user) } }
    let(:base_params) do
      {
        service_type: 'Ligação Nova',
        customer_id: create(:customer).id,
        concessionaire_id: create(:concessionaire).id,
        opening_date: Date.today.iso8601,
        amount: '150.00'
      }
    end

    it 'creates apportionments and entry items with the service' do
      post '/services', headers: headers, as: :json, params: base_params.merge(
        apportionments_attributes: [{ consumer_unit: 'UC-9', address: 'Rua X', classification: 'B1', percentage: 50 }],
        service_entry_items_attributes: [{ connection_type: 'Trifásico', classification: 'Comercial', quantity: 2,
                                           circuit_breaker: '40A' }]
      )

      body = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(body['apportionments'].pluck('consumer_unit')).to eq(['UC-9'])
      expect(body['service_entry_items'].pluck('connection_type')).to eq(['Trifásico'])
    end

    it 'removes nested records flagged with _destroy' do
      service = create(:service)
      apportionment = create(:apportionment, service: service)
      item = create(:service_entry_item, service: service)

      patch "/services/#{service.id}", headers: headers, as: :json, params: {
        apportionments_attributes: [{ id: apportionment.id, _destroy: true }],
        service_entry_items_attributes: [{ id: item.id, _destroy: true }]
      }

      expect(response).to have_http_status(:ok)
      expect(service.reload.apportionments).to be_empty
      expect(service.service_entry_items).to be_empty
    end
  end

  describe 'access scope' do
    let(:owner) { create(:user) }
    let(:other) { create(:user) }
    let(:admin) { create(:user, profile: 'admin') }
    let!(:service) { with_current_user(owner) { create(:service) } }

    def with_current_user(user)
      Current.user = user
      yield
    ensure
      Current.user = nil
    end

    def headers_for(user)
      { 'Authorization' => auth_token_for(user) }
    end

    it 'lists only the integrator own services' do
      with_current_user(other) { create(:service) }

      get '/services', headers: headers_for(owner)
      expect(JSON.parse(response.body).pluck('id')).to eq([service.id])
    end

    it 'lists every service for admins' do
      with_current_user(other) { create(:service) }

      get '/services', headers: headers_for(admin)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it 'paginates only the integrator own services' do
      with_current_user(other) { create(:service) }

      get '/services/paginate', headers: headers_for(owner)
      expect(JSON.parse(response.body)['content'].pluck('id')).to eq([service.id])
    end

    it 'hides another integrator service' do
      get "/services/#{service.id}", headers: headers_for(other)
      expect(response).to have_http_status(:not_found)
    end

    it 'does not let another integrator update it' do
      patch "/services/#{service.id}", headers: headers_for(other), as: :json, params: { observations: 'x' }
      expect(response).to have_http_status(:not_found)
    end

    it 'does not let another integrator delete it' do
      delete "/services/#{service.id}", headers: headers_for(other)
      expect(response).to have_http_status(:not_found)
      expect(Service.exists?(service.id)).to be(true)
    end

    it 'rejects requests without a token' do
      get '/services'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
