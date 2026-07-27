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
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
