# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Projects', type: :request do
  include_context 'with auth token'

  path '/projects' do
    get 'Lista todos os projetos' do
      tags 'Projects'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'lista de projetos' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Project' }
        run_test!
      end
    end

    post 'Cria um projeto' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :project, in: :body, schema: {
        type: :object,
        required: %w[client_id utility_company utility_protocol customer_class
                     integrator modality framework unit_control project_type],
        properties: {
          client_id: { type: :string, format: :uuid },
          address_id: { type: :string, format: :uuid, nullable: true },
          utility_company: { type: :string },
          utility_protocol: { type: :string },
          customer_class: { type: :string },
          integrator: { type: :string },
          modality: { type: :string },
          framework: { type: :string },
          status: { type: :string },
          amount: { type: :number },
          dc_protection: { type: :string },
          system_power: { type: :number },
          unit_control: { type: :string },
          description: { type: :string },
          project_type: { type: :string },
          fast_track: { type: :boolean },
          coordinates: { type: :string, description: 'WKT — ex: "POINT(-43.9 -19.9)"' },
          services_names: { type: :array, items: { type: :string } }
        }
      }

      response '201', 'projeto criado' do
        let(:project) do
          customer = create(:customer)
          {
            client_id: customer.id, utility_company: 'CEMIG', utility_protocol: 'P001',
            customer_class: 'B1', integrator: 'Int X', modality: 'Micro',
            framework: 'NET', unit_control: 'UC-1', project_type: 'Residencial'
          }
        end
        schema '$ref' => '#/components/schemas/Project'
        run_test! do
          created = Project.last
          expect(created.created_by).to eq(user.id)
          expect(created.updated_by).to eq(user.id)
        end
      end

      response '422', 'cliente não encontrado' do
        let(:project) do
          {
            client_id: SecureRandom.uuid, utility_company: 'CEMIG', utility_protocol: 'P001',
            customer_class: 'B1', integrator: 'Int X', modality: 'Micro',
            framework: 'NET', unit_control: 'UC-1', project_type: 'Residencial'
          }
        end
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/projects/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    get 'Busca um projeto' do
      tags 'Projects'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'projeto encontrado' do
        let(:id) { create(:project).id }
        schema '$ref' => '#/components/schemas/Project'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Atualiza um projeto' do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string },
          description: { type: :string },
          fast_track: { type: :boolean },
          system_power: { type: :number }
        }
      }

      response '200', 'projeto atualizado' do
        let(:id)      { create(:project).id }
        let(:project) { { status: 'aprovado', fast_track: true } }
        schema '$ref' => '#/components/schemas/Project'
        run_test! do
          expect(Project.find(id).updated_by).to eq(user.id)
        end
      end
    end

    delete 'Remove um projeto' do
      tags 'Projects'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'removido com sucesso' do
        let(:id) { create(:project).id }
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
