# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Project Statuses', type: :request do
  include_context 'with auth token'

  path '/projects/{project_id}/statuses' do
    parameter name: :project_id, in: :path, type: :string, format: :uuid, required: true

    get 'Lista os status do projeto' do
      tags 'Projects'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de status' do
        let(:project)    { create(:project) }
        let(:project_id) { project.id }
        before { create_list(:project_status, 2, project: project) }
        schema type: :array, items: { '$ref' => '#/components/schemas/ProjectStatus' }
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

    post 'Registra um novo status no projeto' do
      let(:user) { create(:user, profile: 'main') }

      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :body, in: :body, schema: {
        type: :object,
        required: ['name'],
        properties: {
          name: { type: :string, description: 'Nome do novo status' },
          comment: { type: :string, description: 'Comentário inicial (opcional)', nullable: true }
        }
      }

      response '201', 'status registrado sem comentário' do
        let(:project_id) { create(:project).id }
        let(:body) { { name: 'aprovado' } }
        schema '$ref' => '#/components/schemas/ProjectStatus'
        run_test! do
          expect(response_body['name']).to eq('aprovado')
          expect(response_body['comments']).to eq([])
          expect(Project.find(project_id).status).to eq('aprovado')
        end
      end

      response '201', 'status registrado com comentário' do
        let(:project_id) { create(:project).id }
        let(:body) { { name: 'aprovado', comment: 'Documentação validada' } }
        schema '$ref' => '#/components/schemas/ProjectStatus'
        run_test! do
          expect(response_body['comments'].first['body']).to eq('Documentação validada')
        end
      end

      response '422', 'nome em branco' do
        let(:project_id) { create(:project).id }
        let(:body) { { name: '' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '404', 'projeto não encontrado' do
        let(:project_id) { SecureRandom.uuid }
        let(:body) { { name: 'aprovado' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
