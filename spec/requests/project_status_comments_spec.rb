# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Project Status Comments', type: :request do
  include_context 'with auth token'

  let(:project)       { create(:project) }
  let(:project_id)    { project.id }
  let(:status_record) { create(:project_status, project: project) }
  let(:status_id)     { status_record.id }

  path '/projects/{project_id}/statuses/{status_id}/comments' do
    parameter name: :project_id, in: :path, type: :string, format: :uuid, required: true
    parameter name: :status_id,  in: :path, type: :string, format: :uuid, required: true

    post 'Adiciona um comentário ao status' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: ['body'],
        properties: { body: { type: :string } }
      }

      response '201', 'comentário criado' do
        let(:body) { { body: 'Aguardando documentação' } }
        schema '$ref' => '#/components/schemas/ProjectStatusComment'
        run_test!
      end

      response '422', 'body em branco' do
        let(:body) { { body: '' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '404', 'status não encontrado' do
        let(:status_id) { SecureRandom.uuid }
        let(:body)      { { body: 'Comentário' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/projects/{project_id}/statuses/{status_id}/comments/{id}' do
    parameter name: :project_id, in: :path, type: :string, format: :uuid, required: true
    parameter name: :status_id,  in: :path, type: :string, format: :uuid, required: true
    parameter name: :id,         in: :path, type: :string, format: :uuid, required: true

    patch 'Atualiza um comentário' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: ['body'],
        properties: { body: { type: :string } }
      }

      response '200', 'comentário atualizado' do
        let(:comment) { create(:project_status_comment, project_status: status_record) }
        let(:id)      { comment.id }
        let(:body)    { { body: 'Texto atualizado' } }
        schema '$ref' => '#/components/schemas/ProjectStatusComment'
        run_test!
      end

      response '404', 'comentário não encontrado' do
        let(:id)   { SecureRandom.uuid }
        let(:body) { { body: 'Texto' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete 'Remove um comentário' do
      tags 'Projects'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:comment) { create(:project_status_comment, project_status: status_record) }
        let(:id)      { comment.id }
        run_test!
      end

      response '404', 'comentário não encontrado' do
        let(:id) { SecureRandom.uuid }
        run_test!
      end
    end
  end
end
