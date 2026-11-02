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
                     modality framework unit_control project_type],
        properties: {
          client_id: { type: :string, format: :uuid },
          address_id: { type: :string, format: :uuid, nullable: true },
          utility_company: { type: :string },
          utility_protocol: { type: :string },
          secondary_protocol: { type: :string },
          customer_class: { type: :string },
          integrator: { type: :string, format: :uuid, nullable: true },
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
            customer_class: 'B1', integrator: create(:user).id, modality: 'Micro',
            framework: 'NET', unit_control: 'UC-1', project_type: 'Residencial'
          }
        end
        schema '$ref' => '#/components/schemas/Project'
        run_test! do
          created = Project.find(JSON.parse(response.body)['id'])
          expect(created.created_by).to eq(user.id)
          expect(created.updated_by).to eq(user.id)
        end
      end

      response '422', 'cliente não encontrado' do
        let(:project) do
          {
            client_id: SecureRandom.uuid, utility_company: 'CEMIG', utility_protocol: 'P001',
            customer_class: 'B1', modality: 'Micro',
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
      let(:user) { create(:user, profile: 'admin') }

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
      let(:user) { create(:user, profile: 'admin') }

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

  path '/projects/{id}/inactivate' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    patch 'Inativa um projeto' do
      let(:user) { create(:user, profile: 'admin') }

      tags 'Projects'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'projeto inativado' do
        let(:id) { create(:project).id }
        run_test! do
          expect(Project.unscoped.find(id).deleted_at).to be_present
          expect(Project.find_by(id: id)).to be_nil
        end
      end

      response '404', 'não encontrado' do
        let(:id) { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  describe 'GET /projects performance' do
    let(:headers) { { 'Authorization' => auth_token_for(user) } }

    def create_projects(count)
      count.times do
        project = create(:project, integrator: create(:user).id)
        create(:project_status, project: project).tap { create(:project_status_comment, project_status: _1) }
      end
    end

    def queries_for_index
      count = 0
      counter = ->(*, payload) { count += 1 unless payload[:name] == 'SCHEMA' }
      ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { get '/projects', headers: headers }
      count
    end

    it 'does not run extra queries per project' do
      create_projects(2)
      baseline = queries_for_index

      create_projects(5)
      expect(queries_for_index).to eq(baseline)
    end

    it 'returns statuses ordered by creation' do
      project = create(:project)
      newer = create(:project_status, project: project, created_at: 1.hour.ago)
      older = create(:project_status, project: project, created_at: 2.hours.ago)

      get '/projects', headers: headers
      statuses = JSON.parse(response.body).find { _1['id'] == project.id }['statuses']
      expect(statuses.pluck('id')).to eq([older.id, newer.id])
    end
  end
end
