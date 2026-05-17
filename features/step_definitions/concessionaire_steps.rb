# frozen_string_literal: true

require 'json'

SAMPLE_LOGO = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='

# --- Contexto ---

Dado('que existe uma concessionária cadastrada') do
  @concessionaire = create(:concessionaire, name: 'CEMIG', created_by: @current_user.id)
end

# --- Requisições HTTP ---

Quando('faço POST em {string} com logo em base64') do |path|
  resolved = resolve_concessionaire_path(path)
  payload = { name: 'Com Logo', active: true, logo: SAMPLE_LOGO }
  post resolved, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  @response_body = begin
    JSON.parse(last_response.body)
  rescue StandardError
    nil
  end
end

Quando('faço PATCH em {string} com logo em base64') do |path|
  resolved = resolve_concessionaire_path(path)
  payload = { logo: SAMPLE_LOGO }
  patch resolved, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  @response_body = begin
    JSON.parse(last_response.body)
  rescue StandardError
    nil
  end
end

# --- Asserções ---

Então('a concessionária foi criada no banco') do
  expect(Concessionaire.exists?(name: @response_body['name'])).to be true
end

Então('a concessionária não existe mais no banco') do
  expect(Concessionaire.exists?(@concessionaire.id)).to be false
end

Então('a resposta contém um logo comprimido') do
  expect(@response_body['logo']).to start_with('data:image/')
end

# --- Helpers ---

def resolve_concessionaire_path(path)
  path.gsub('<concessionaire_id>', @concessionaire&.id.to_s)
end
