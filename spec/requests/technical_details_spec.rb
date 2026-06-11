# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Technical Details', type: :request do
  include_context 'with auth token'

  path '/projects/{project_id}/technical_details' do
    parameter name: :project_id, in: :path, type: :string, format: :uuid, required: true

    get 'Lista os detalhes técnicos do projeto' do
      tags 'Projects'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de detalhes técnicos' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        before { create_list(:technical_detail, 2, project: project) }
        schema type: :array, items: { '$ref' => '#/components/schemas/TechnicalDetail' }
        run_test! do
          expect(response_body.length).to eq(2)
        end
      end

      response '404', 'projeto não encontrado' do
        let(:project_id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    post 'Cria um detalhe técnico no projeto' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :technical_detail, in: :body, schema: {
        type: :object,
        properties: {
          opening_date: { type: :string, format: :date, nullable: true },
          supply_voltage: { type: :string, nullable: true },
          new_project: { type: :boolean },
          zero_grid_control: { type: :boolean },
          modules: { type: :array, items: { type: :string } },
          inverters: { type: :array, items: { type: :string } },
          entry_standard_items: { type: :array, items: { type: :string } },
          credit_divisions: { type: :array, items: { type: :string } }
        }
      }

      response '201', 'detalhe técnico criado' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        let(:technical_detail) do
          {
            opening_date: '2026-06-01', supply_voltage: '220V', new_project: true,
            zero_grid_control: false, modules: ['Canadian 550W x12'],
            inverters: ['Growatt 5kW'], entry_standard_items: ['Disjuntor 63A'],
            credit_divisions: ['UC-123: 60%']
          }
        end
        schema '$ref' => '#/components/schemas/TechnicalDetail'
        run_test! do
          expect(response_body['supply_voltage']).to eq('220V')
          expect(response_body['modules']).to eq(['Canadian 550W x12'])
          expect(response_body['created_by']).to eq(user.id)
        end
      end

      response '404', 'projeto não encontrado' do
        let(:project_id) { SecureRandom.uuid }
        let(:technical_detail) { { supply_voltage: '220V' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/projects/{project_id}/technical_details/{id}' do
    parameter name: :project_id, in: :path, type: :string, format: :uuid, required: true
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Mostra um detalhe técnico' do
      tags 'Projects'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'detalhe técnico encontrado' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        let(:id)         { create(:technical_detail, project: project).id }
        schema '$ref' => '#/components/schemas/TechnicalDetail'
        run_test! do
          expect(response_body['supply_voltage']).to eq('220V')
        end
      end

      response '404', 'detalhe técnico não encontrado' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        let(:id)         { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um detalhe técnico' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :technical_detail, in: :body, schema: {
        type: :object,
        properties: {
          supply_voltage: { type: :string },
          zero_grid_control: { type: :boolean },
          inverters: { type: :array, items: { type: :string } }
        }
      }

      response '200', 'detalhe técnico atualizado' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        let(:id)         { create(:technical_detail, project: project).id }
        let(:technical_detail) { { supply_voltage: '380V', zero_grid_control: true } }
        schema '$ref' => '#/components/schemas/TechnicalDetail'
        run_test! do
          expect(response_body['supply_voltage']).to eq('380V')
          expect(response_body['zero_grid_control']).to be(true)
        end
      end
    end

    delete 'Remove um detalhe técnico' do
      tags 'Projects'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        let(:id)         { create(:technical_detail, project: project).id }
        run_test! do
          expect(TechnicalDetail.exists?(id)).to be(false)
        end
      end
    end
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
