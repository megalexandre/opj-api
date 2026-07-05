# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Access Control', type: :request do
  let(:main_user) { create(:user, profile: 'admin') }
  let(:user_a)    { create(:user, profile: 'user') }
  let(:user_b)    { create(:user, profile: 'user') }

  let(:main_headers) { { 'Authorization' => auth_token_for(main_user) } }
  let(:headers_a)    { { 'Authorization' => auth_token_for(user_a) } }
  let(:headers_b)    { { 'Authorization' => auth_token_for(user_b) } }

  before do
    Current.user = user_a
    create(:project)
    Current.user = user_b
    create(:project)
    Current.user = nil
  end

  describe 'GET /projects (index)' do
    it 'main sees all projects' do
      get '/projects', headers: main_headers
      ids = JSON.parse(response.body).map { |p| p['created_by'] }
      expect(ids).to include(user_a.id, user_b.id)
    end

    it 'non-main sees only own projects' do
      get '/projects', headers: headers_a
      ids = JSON.parse(response.body).map { |p| p['created_by'] }
      expect(ids).to all(eq(user_a.id))
    end

    it 'non-main sees only own count' do
      get '/projects', headers: headers_b
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it 'main sees projects as editable' do
      get '/projects', headers: main_headers
      expect(JSON.parse(response.body).map { |p| p['editable'] }).to all(be(true))
    end

    it 'non-main sees projects as not editable' do
      get '/projects', headers: headers_a
      expect(JSON.parse(response.body).map { |p| p['editable'] }).to all(be(false))
    end
  end

  describe 'GET /projects/:id (show)' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }

    it 'main can show any project' do
      get "/projects/#{project_a.id}", headers: main_headers
      expect(response).to have_http_status(:ok)
    end

    it 'owner can show own project' do
      get "/projects/#{project_a.id}", headers: headers_a
      expect(response).to have_http_status(:ok)
    end

    it 'non-owner gets 404' do
      get "/projects/#{project_a.id}", headers: headers_b
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /projects/:id (update)' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }

    it 'main can update any project' do
      patch "/projects/#{project_a.id}",
            params: { status: 'aprovado' }.to_json,
            headers: main_headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:ok)
    end

    it 'owner gets 403' do
      patch "/projects/#{project_a.id}",
            params: { status: 'aprovado' }.to_json,
            headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:forbidden)
    end

    it 'non-owner gets 404' do
      patch "/projects/#{project_a.id}",
            params: { status: 'aprovado' }.to_json,
            headers: headers_b.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /projects/:id (destroy)' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }

    it 'main can delete any project' do
      delete "/projects/#{project_a.id}", headers: main_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'owner gets 403' do
      delete "/projects/#{project_a.id}", headers: headers_a
      expect(response).to have_http_status(:forbidden)
    end

    it 'non-owner gets 404' do
      delete "/projects/#{project_a.id}", headers: headers_b
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /projects/:project_id/statuses (kanban move)' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }

    it 'main can create a status on any project' do
      post "/projects/#{project_a.id}/statuses",
           params: { name: 'aprovado' }.to_json,
           headers: main_headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:created)
    end

    it 'owner gets 403' do
      post "/projects/#{project_a.id}/statuses",
           params: { name: 'aprovado' }.to_json,
           headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:forbidden)
    end

    it 'non-owner gets 404' do
      post "/projects/#{project_a.id}/statuses",
           params: { name: 'aprovado' }.to_json,
           headers: headers_b.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /projects/:project_id/statuses (index)' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }

    it 'owner can list statuses' do
      get "/projects/#{project_a.id}/statuses", headers: headers_a
      expect(response).to have_http_status(:ok)
    end

    it 'non-owner gets 404' do
      get "/projects/#{project_a.id}/statuses", headers: headers_b
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'project assigned to an integrator' do
    let!(:assigned_project) do
      Current.user = main_user
      project = create(:project, integrator: user_a.id)
      Current.user = nil
      project
    end

    it 'integrator sees the project in the kanban list' do
      get '/projects', headers: headers_a
      ids = JSON.parse(response.body).map { |p| p['id'] }
      expect(ids).to include(assigned_project.id)
    end

    it 'integrator can show the project' do
      get "/projects/#{assigned_project.id}", headers: headers_a
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['editable']).to be(false)
    end

    it 'integrator can list project statuses' do
      get "/projects/#{assigned_project.id}/statuses", headers: headers_a
      expect(response).to have_http_status(:ok)
    end

    it 'integrator cannot update the project' do
      patch "/projects/#{assigned_project.id}",
            params: { description: 'mudou' }.to_json,
            headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:forbidden)
    end

    it 'integrator cannot delete the project' do
      delete "/projects/#{assigned_project.id}", headers: headers_a
      expect(response).to have_http_status(:forbidden)
    end

    it 'integrator cannot move the project on the kanban' do
      post "/projects/#{assigned_project.id}/statuses",
           params: { name: 'aprovado' }.to_json,
           headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:forbidden)
    end

    it 'other non-main users still get 404' do
      get "/projects/#{assigned_project.id}", headers: headers_b
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'technical details' do
    let!(:project_a) { Project.find_by(created_by: user_a.id) }
    let(:payload) { { supply_voltage: '220V' }.to_json }
    let(:json_headers) { { 'Content-Type' => 'application/json' } }

    it 'owner can create a technical detail' do
      post "/projects/#{project_a.id}/technical_details",
           params: payload, headers: headers_a.merge(json_headers)
      expect(response).to have_http_status(:created)
    end

    it 'main can create a technical detail on any project' do
      post "/projects/#{project_a.id}/technical_details",
           params: payload, headers: main_headers.merge(json_headers)
      expect(response).to have_http_status(:created)
    end

    it 'non-owner cannot create and gets 404' do
      post "/projects/#{project_a.id}/technical_details",
           params: payload, headers: headers_b.merge(json_headers)
      expect(response).to have_http_status(:not_found)
    end

    context 'when the project is assigned to an integrator' do
      let!(:assigned_project) do
        Current.user = main_user
        project = create(:project, integrator: user_b.id)
        Current.user = nil
        project
      end

      it 'integrator can list technical details' do
        get "/projects/#{assigned_project.id}/technical_details", headers: headers_b
        expect(response).to have_http_status(:ok)
      end

      it 'integrator can create technical details' do
        post "/projects/#{assigned_project.id}/technical_details",
             params: payload, headers: headers_b.merge(json_headers)
        expect(response).to have_http_status(:created)
      end

      it 'integrator can update technical details' do
        Current.user = main_user
        td = assigned_project.technical_details.create!(supply_voltage: '110V')
        Current.user = nil

        patch "/projects/#{assigned_project.id}/technical_details/#{td.id}",
              params: { supply_voltage: '220V' }.to_json,
              headers: headers_b.merge(json_headers)
        expect(response).to have_http_status(:ok)
      end

      it 'integrator can delete technical details' do
        Current.user = main_user
        td = assigned_project.technical_details.create!(supply_voltage: '110V')
        Current.user = nil

        delete "/projects/#{assigned_project.id}/technical_details/#{td.id}",
               headers: headers_b
        expect(response).to have_http_status(:no_content)
      end

      it 'other user cannot create on assigned project' do
        post "/projects/#{assigned_project.id}/technical_details",
             params: payload, headers: headers_a.merge(json_headers)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /auth/register' do
    it 'unauthenticated user gets 401' do
      post '/auth/register',
           params: { name: 'New User', email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123', profile: 'user' }.to_json,
           headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'regular user gets 403' do
      post '/auth/register',
           params: { name: 'New User', email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123', profile: 'user' }.to_json,
           headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:forbidden)
    end

    it 'admin can create a new user' do
      post '/auth/register',
           params: { name: 'New User', email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123', profile: 'user' }.to_json,
           headers: main_headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['user']['profile']).to eq('user')
    end
  end
end
