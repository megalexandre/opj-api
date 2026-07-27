# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Calendar Events', type: :request do
  include_context 'with auth token'

  path '/calendar_events' do
    get 'Lista os eventos do calendário em um período' do
      tags 'Calendar Events'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :from, in: :query, type: :string, format: :date, required: false,
                description: 'Data inicial (inclusive)'
      parameter name: :to, in: :query, type: :string, format: :date, required: false,
                description: 'Data final (inclusive)'

      response '200', 'lista filtrada por período' do
        let(:from) { '2026-07-10' }
        let(:to)   { '2026-07-20' }
        before do
          create(:calendar_event, date: '2026-07-15', content: { title: 'Dentro' })
          create(:calendar_event, date: '2026-08-01', content: { title: 'Fora' })
        end
        schema type: :array, items: { '$ref' => '#/components/schemas/CalendarEvent' }
        run_test! do
          expect(response_body.length).to eq(1)
          expect(response_body.first['content']).to eq('title' => 'Dentro')
        end
      end

      response '200', 'lista completa sem filtro, incluindo vários itens na mesma data' do
        let(:from) { nil }
        let(:to)   { nil }
        before { create_list(:calendar_event, 2, date: '2026-07-15') }
        schema type: :array, items: { '$ref' => '#/components/schemas/CalendarEvent' }
        run_test! do
          expect(response_body.length).to eq(2)
          expect(response_body.map { |e| e['date'] }).to all(eq('2026-07-15'))
        end
      end
    end

    post 'Cria um evento no calendário' do
      tags 'Calendar Events'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :calendar_event, in: :body, schema: {
        type: :object,
        properties: {
          date: { type: :string, format: :date },
          content: { type: :object }
        },
        required: %w[date]
      }

      response '201', 'evento criado' do
        let(:calendar_event) { { date: '2026-07-26', content: { title: 'Reunião', qualquer_campo: 123 } } }
        schema '$ref' => '#/components/schemas/CalendarEvent'
        run_test! do
          expect(response_body['date']).to eq('2026-07-26')
          expect(response_body['content']).to eq('title' => 'Reunião', 'qualquer_campo' => 123)
          expect(response_body['created_by']).to eq(user.id)
        end
      end

      response '422', 'data ausente' do
        let(:calendar_event) { { content: { title: 'Sem data' } } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/calendar_events/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Mostra um evento do calendário' do
      tags 'Calendar Events'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'evento encontrado' do
        let(:id) { create(:calendar_event, content: { title: 'Evento' }).id }
        schema '$ref' => '#/components/schemas/CalendarEvent'
        run_test! do
          expect(response_body['content']).to eq('title' => 'Evento')
        end
      end

      response '404', 'evento não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um evento do calendário' do
      tags 'Calendar Events'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :calendar_event, in: :body, schema: {
        type: :object,
        properties: {
          date: { type: :string, format: :date },
          content: { type: :object }
        }
      }

      response '200', 'evento atualizado' do
        let(:id) { create(:calendar_event, content: { title: 'Original' }).id }
        let(:calendar_event) { { content: { title: 'Atualizado' } } }
        schema '$ref' => '#/components/schemas/CalendarEvent'
        run_test! do
          expect(response_body['content']).to eq('title' => 'Atualizado')
        end
      end
    end

    delete 'Remove um evento do calendário' do
      tags 'Calendar Events'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:calendar_event).id }
        run_test! do
          expect(CalendarEvent.exists?(id)).to be(false)
        end
      end
    end
  end

  describe 'isolamento entre usuários' do
    let(:other_user) { create(:user) }
    let!(:other_event) do
      Current.user = other_user
      create(:calendar_event)
    end

    it 'não permite acessar evento de outro usuário' do
      get "/calendar_events/#{other_event.id}", headers: { 'Authorization' => auth_token_for(user) }
      expect(response).to have_http_status(:not_found)
    end

    it 'não permite atualizar evento de outro usuário' do
      patch "/calendar_events/#{other_event.id}",
            params: { content: { title: 'Invadido' } }.to_json,
            headers: { 'Authorization' => auth_token_for(user), 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end

    it 'não permite remover evento de outro usuário' do
      expect do
        delete "/calendar_events/#{other_event.id}", headers: { 'Authorization' => auth_token_for(user) }
      end.not_to change(CalendarEvent, :count)
      expect(response).to have_http_status(:not_found)
    end

    it 'não lista evento de outro usuário no índice' do
      get '/calendar_events', headers: { 'Authorization' => auth_token_for(user) }
      ids = JSON.parse(response.body).map { |e| e['id'] }
      expect(ids).not_to include(other_event.id)
    end

    it 'admin vê eventos de todos os usuários no índice' do
      admin = create(:user, profile: 'admin')
      get '/calendar_events', headers: { 'Authorization' => auth_token_for(admin) }
      ids = JSON.parse(response.body).map { |e| e['id'] }
      expect(ids).to include(other_event.id)
    end
  end

  describe 'vínculo com projeto e filtros parciais de data' do
    it 'aceita project_id opcional na criação' do
      project = create(:project)
      post '/calendar_events',
           params: { date: '2026-07-26', project_id: project.id, content: {} }.to_json,
           headers: { 'Authorization' => auth_token_for(user), 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['project_id']).to eq(project.id)
    end

    it 'filtra somente com from' do
      create(:calendar_event, date: '2026-07-10')
      create(:calendar_event, date: '2026-07-20')
      get '/calendar_events', params: { from: '2026-07-15' },
                               headers: { 'Authorization' => auth_token_for(user) }
      dates = JSON.parse(response.body).map { |e| e['date'] }
      expect(dates).to eq(['2026-07-20'])
    end

    it 'filtra somente com to' do
      create(:calendar_event, date: '2026-07-10')
      create(:calendar_event, date: '2026-07-20')
      get '/calendar_events', params: { to: '2026-07-15' },
                               headers: { 'Authorization' => auth_token_for(user) }
      dates = JSON.parse(response.body).map { |e| e['date'] }
      expect(dates).to eq(['2026-07-10'])
    end
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
