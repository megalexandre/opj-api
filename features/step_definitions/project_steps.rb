# frozen_string_literal: true

require 'json'

# --- Contexto e autenticação ---

Dado('que estou autenticado como usuário') do
  @user = create(:user)
  set_auth_header(@user)
  Current.user = @user
end

Dado('que estou autenticado como administrador') do
  @user = create(:user, profile: 'main')
  set_auth_header(@user)
  Current.user = @user
end

Dado('que existe um cliente cadastrado') do
  @customer = create(:customer)
end

Dado('que existe um projeto cadastrado') do
  @customer ||= create(:customer)
  @project = create(:project, client: @customer)
end

# --- Requisições HTTP ---

Quando('faço GET em {string}') do |path|
  resolved = resolve_path(path)
  get resolved
  @response_body = begin
    JSON.parse(last_response.body)
  rescue StandardError
    nil
  end
end

Quando('faço POST em {string} com os dados:') do |path, table|
  resolved = resolve_path(path)
  payload = build_payload(table.rows_hash)
  post resolved, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  @response_body = begin
    JSON.parse(last_response.body)
  rescue StandardError
    nil
  end
end

Quando('faço PATCH em {string} com os dados:') do |path, table|
  resolved = resolve_path(path)
  payload = build_payload(table.rows_hash)
  patch resolved, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  @response_body = begin
    JSON.parse(last_response.body)
  rescue StandardError
    nil
  end
end

Quando('faço DELETE em {string}') do |path|
  resolved = resolve_path(path)
  delete resolved
end

# --- Asserções ---

Então('o status da resposta é {int}') do |status|
  expect(last_response.status).to eq(status)
end

Então('a resposta é uma lista vazia') do
  expect(@response_body).to eq([])
end

Então('a resposta contém {string} com valor {string}') do |key, value|
  expect(@response_body[key].to_s).to eq(value)
end

Então('o projeto foi criado com {string} do usuário autenticado') do |field|
  created = Project.last
  expect(created.public_send(field)).to eq(@user.id)
end

Então('o projeto tem um registro de status {string}') do |status_name|
  project = Project.last
  expect(project.statuses.pluck(:name)).to include(status_name)
end

Então('o projeto não existe mais no banco') do
  expect(Project.exists?(@project.id)).to be false
end

Então('o status atual do projeto é {string}') do |status_name|
  expect(@project.reload.status).to eq(status_name)
end

Então('o projeto tem {int} registros de status') do |count|
  expect(@project.reload.statuses.count).to eq(count)
end

Então('o status criado tem comentário {string}') do |body|
  status = @project.reload.statuses.last
  expect(status.comments.first&.body).to eq(body)
end

Dado('que o projeto tem {int} status cadastrados') do |count|
  count.times { |i| create(:project_status, project: @project, name: "status_#{i}") }
end

Então('a resposta contém uma lista com {int} itens') do |count|
  expect(@response_body.length).to eq(count)
end

# --- Helpers ---

def resolve_path(path)
  path
    .gsub('<project_id>',        @project&.id.to_s)
    .gsub('<client_id>',         @customer&.id.to_s)
    .gsub('<status_id>',         @status&.id.to_s)
    .gsub('<comment_id>',        @comment&.id.to_s)
    .gsub('<concessionaire_id>', @concessionaire&.id.to_s)
end

def build_payload(hash)
  hash.transform_values do |v|
    case v
    when '<client_id>'  then @customer&.id.to_s
    when '<project_id>' then @project&.id.to_s
    when 'true'         then true
    when 'false'        then false
    else v
    end
  end
end
