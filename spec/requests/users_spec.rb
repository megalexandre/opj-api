# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users', type: :request do
  include_context 'with auth token'

  path '/users/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    delete 'Remove um usuário' do
      tags 'Users'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'usuário removido' do
        let(:user) { create(:user, profile: 'admin') }
        let(:id)   { create(:user).id }
        run_test! do
          expect(User.exists?(id)).to be(false)
        end
      end

      response '403', 'usuário sem permissão' do
        let(:id) { create(:user).id }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '404', 'não encontrado' do
        let(:user) { create(:user, profile: 'admin') }
        let(:id)   { SecureRandom.uuid }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/users/{id}/reset_password' do
    parameter name: :id, in: :path, type: :string, format: :uuid, required: true

    patch 'Redefine a senha de um usuário' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      parameter name: :password_reset, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string },
          password_confirmation: { type: :string }
        }
      }

      response '200', 'senha redefinida' do
        let(:user)   { create(:user, profile: 'admin') }
        let(:target) { create(:user) }
        let(:id)     { target.id }
        let(:password_reset) { { password: 'novaSenha123', password_confirmation: 'novaSenha123' } }
        schema '$ref' => '#/components/schemas/User'
        run_test! do
          expect(target.reload.authenticate('novaSenha123')).to be_truthy
        end
      end

      response '403', 'usuário sem permissão' do
        let(:id) { create(:user).id }
        let(:password_reset) { { password: 'novaSenha123', password_confirmation: 'novaSenha123' } }
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '422', 'confirmação de senha não confere' do
        let(:user) { create(:user, profile: 'admin') }
        let(:id)   { create(:user).id }
        let(:password_reset) { { password: 'novaSenha123', password_confirmation: 'outraSenha' } }
        run_test!
      end
    end
  end

  describe 'proteção contra autoexclusão' do
    it 'não permite que o admin exclua a própria conta' do
      admin = create(:user, profile: 'admin')

      expect do
        delete "/users/#{admin.id}", headers: { 'Authorization' => auth_token_for(admin) }
      end.not_to change(User, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
