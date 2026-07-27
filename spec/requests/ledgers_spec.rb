# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Ledgers', type: :request do
  include_context 'with auth token'

  path '/ledgers' do
    get 'Lista todos os lançamentos' do
      tags 'Ledgers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de lançamentos' do
        before { create_list(:ledger, 2) }
        schema type: :array, items: { '$ref' => '#/components/schemas/Ledger' }
        run_test! do
          expect(response_body.length).to eq(2)
        end
      end
    end

    post 'Cria um lançamento' do
      tags 'Ledgers'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :ledger, in: :body, schema: {
        type: :object,
        properties: {
          project_id: { type: :string, format: :uuid, nullable: true },
          service_id: { type: :string, format: :uuid, nullable: true },
          amount: { type: :string },
          reason: { type: :string },
          description: { type: :string },
          paid_at: { type: :string, format: :'date-time' }
        },
        required: %w[amount]
      }

      response '201', 'lançamento criado' do
        let(:ledger) { { amount: '150,75', reason: 'Pagamento fornecedor' } }
        schema '$ref' => '#/components/schemas/Ledger'
        run_test! do
          expect(response_body['amount_cents']).to eq(15_075)
          expect(response_body['reason']).to eq('Pagamento fornecedor')
          expect(Ledger.find(response_body['id']).created_by).to eq(user.id)
        end
      end

      response '422', 'formato de valor inválido' do
        let(:ledger) { { amount: '150.75', reason: 'Formato americano' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/ledgers/paginate' do
    get 'Lista lançamentos paginados' do
      tags 'Ledgers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :page,  in: :query, type: :integer, required: false, description: 'Página (começa em 1)'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Itens por página'
      parameter name: :project_id, in: :query, type: :string, format: :uuid, required: false
      parameter name: :service_id, in: :query, type: :string, format: :uuid, required: false
      parameter name: :reason, in: :query, type: :string, required: false
      parameter name: :from, in: :query, type: :string, format: :'date-time', required: false
      parameter name: :to,   in: :query, type: :string, format: :'date-time', required: false

      response '200', 'página de lançamentos' do
        before { create_list(:ledger, 3) }
        schema allOf: [
          { '$ref' => '#/components/schemas/Page' },
          {
            type: :object,
            properties: {
              content: { type: :array, items: { '$ref' => '#/components/schemas/Ledger' } }
            }
          }
        ]
        run_test! do
          expect(response_body['content'].length).to eq(3)
        end
      end
    end
  end

  path '/ledgers/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Mostra um lançamento' do
      tags 'Ledgers'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lançamento encontrado' do
        let(:id) { create(:ledger, amount_cents: 500).id }
        schema '$ref' => '#/components/schemas/Ledger'
        run_test! do
          expect(response_body['amount_cents']).to eq(500)
        end
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um lançamento' do
      tags 'Ledgers'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :ledger, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string },
          description: { type: :string }
        }
      }

      response '200', 'lançamento atualizado' do
        let(:id)     { create(:ledger).id }
        let(:ledger) { { reason: 'Atualizado' } }
        schema '$ref' => '#/components/schemas/Ledger'
        run_test! do
          expect(response_body['reason']).to eq('Atualizado')
        end
      end
    end

    delete 'Remove um lançamento' do
      tags 'Ledgers'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:ledger).id }
        run_test! do
          expect(Ledger.exists?(id)).to be(false)
        end
      end
    end
  end

  describe 'isolamento entre usuários' do
    let(:other_user) { create(:user) }
    let!(:other_ledger) do
      Current.user = other_user
      create(:ledger)
    end

    it 'não permite acessar lançamento de outro usuário' do
      get "/ledgers/#{other_ledger.id}", headers: { 'Authorization' => auth_token_for(user) }
      expect(response).to have_http_status(:not_found)
    end

    it 'não permite atualizar lançamento de outro usuário' do
      patch "/ledgers/#{other_ledger.id}",
            params: { reason: 'Invadido' }.to_json,
            headers: { 'Authorization' => auth_token_for(user), 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end

    it 'não permite remover lançamento de outro usuário' do
      expect do
        delete "/ledgers/#{other_ledger.id}", headers: { 'Authorization' => auth_token_for(user) }
      end.not_to change(Ledger, :count)
      expect(response).to have_http_status(:not_found)
    end

    it 'não lista lançamento de outro usuário no índice' do
      get '/ledgers', headers: { 'Authorization' => auth_token_for(user) }
      ids = JSON.parse(response.body).map { |l| l['id'] }
      expect(ids).not_to include(other_ledger.id)
    end

    it 'admin vê lançamentos de todos os usuários no índice' do
      admin = create(:user, profile: 'admin')
      get '/ledgers', headers: { 'Authorization' => auth_token_for(admin) }
      ids = JSON.parse(response.body).map { |l| l['id'] }
      expect(ids).to include(other_ledger.id)
    end
  end

  describe 'filtros' do
    it 'filtra por project_id' do
      project = create(:project)
      matching = create(:ledger, project: project)
      create(:ledger)

      get '/ledgers/paginate', params: { project_id: project.id },
                                headers: { 'Authorization' => auth_token_for(user) }
      ids = JSON.parse(response.body)['content'].map { |l| l['id'] }
      expect(ids).to eq([matching.id])
    end

    it 'filtra por reason' do
      matching = create(:ledger, reason: 'Compra de material')
      create(:ledger, reason: 'Outro motivo')

      get '/ledgers/paginate', params: { reason: 'Compra de material' },
                                headers: { 'Authorization' => auth_token_for(user) }
      ids = JSON.parse(response.body)['content'].map { |l| l['id'] }
      expect(ids).to eq([matching.id])
    end

    it 'filtra por período de criação (from/to)' do
      old = create(:ledger, created_at: 10.days.ago)
      recent = create(:ledger, created_at: 1.day.ago)

      get '/ledgers/paginate', params: { from: 5.days.ago.to_date.to_s },
                                headers: { 'Authorization' => auth_token_for(user) }
      ids = JSON.parse(response.body)['content'].map { |l| l['id'] }
      expect(ids).to include(recent.id)
      expect(ids).not_to include(old.id)
    end
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
