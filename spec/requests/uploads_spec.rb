# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Uploads', type: :request do
  include_context 'with auth token'

  let(:mock_s3) { instance_double(StorageService) }

  before do
    allow(StorageService).to receive(:new).and_return(mock_s3)
    allow(mock_s3).to receive(:upload).and_return({ url: 'http://localhost:9000/deploy-board-uploads/test/file.pdf' })
    allow(mock_s3).to receive(:delete)

    body_double = instance_double(StringIO, read: 'conteudo', size: 7)
    response_double = double(body: body_double, content_type: 'application/pdf')
    allow(mock_s3).to receive(:download).and_return(response_double)
  end

  path '/uploads' do
    post 'Faz upload de arquivos vinculados a um item' do
      tags 'Uploads'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :item_id, in: :formData, type: :string, format: :uuid, required: true,
                description: 'ID do item ao qual os arquivos pertencem'
      parameter name: :'files[]', in: :formData, type: :array,
                items: { type: :string, format: :binary }, required: true,
                description: 'Um ou mais arquivos'

      response '201', 'arquivos enviados com sucesso' do
        let(:item_id)   { SecureRandom.uuid }
        let(:'files[]') { Rack::Test::UploadedFile.new(StringIO.new('pdf content'), 'application/pdf', original_filename: 'doc.pdf') }
        schema type: :array, items: { '$ref' => '#/components/schemas/Upload' }
        run_test!
      end
    end

    get 'Lista arquivos de um item' do
      tags 'Uploads'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :item_id, in: :query, type: :string, format: :uuid, required: true,
                description: 'ID do item'

      response '200', 'lista de arquivos' do
        let(:item_id) do
          id = SecureRandom.uuid
          create(:upload, item_id: id)
          id
        end
        schema type: :array, items: { '$ref' => '#/components/schemas/Upload' }
        run_test!
      end
    end
  end

  path '/uploads/{id}/download' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
              description: 'ID do upload'

    get 'Faz download de um arquivo' do
      tags 'Uploads'
      produces 'application/octet-stream'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'arquivo retornado' do
        let(:id) { create(:upload).id }
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/uploads/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
              description: 'ID do upload'

    delete 'Remove um arquivo' do
      tags 'Uploads'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:upload).id }
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/uploads/by_item/{item_id}' do
    parameter name: :item_id, in: :path, type: :string, format: :uuid, required: true,
              description: 'ID do item'

    delete 'Remove todos os arquivos de um item' do
      tags 'Uploads'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'quantidade de arquivos removidos' do
        let(:item_id) do
          id = SecureRandom.uuid
          create_list(:upload, 2, item_id: id)
          id
        end
        schema type: :object,
               properties: { deleted: { type: :integer } },
               required: ['deleted']
        run_test!
      end
    end
  end
end
