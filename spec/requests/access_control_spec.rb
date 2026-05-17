# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Access Control', type: :request do
  let(:main_user) { create(:user, profile: 'main') }
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
      expect(JSON.parse(response.body).size).to eq(2)
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

    it 'owner can update own project' do
      patch "/projects/#{project_a.id}",
            params: { status: 'aprovado' }.to_json,
            headers: headers_a.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:ok)
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

    it 'owner can delete own project' do
      delete "/projects/#{project_a.id}", headers: headers_a
      expect(response).to have_http_status(:no_content)
    end

    it 'non-owner gets 404' do
      delete "/projects/#{project_a.id}", headers: headers_b
      expect(response).to have_http_status(:not_found)
    end
  end
end
