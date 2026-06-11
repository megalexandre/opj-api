# language: pt

Funcionalidade: Gerenciamento de Projetos

  Como um usuário autenticado
  Quero gerenciar projetos
  Para acompanhar o ciclo de vida dos projetos de energia solar

  Contexto:
    Dado que estou autenticado como usuário

  Cenário: Listar projetos quando não há nenhum
  
    Quando faço GET em "/projects"
    Então o status da resposta é 200
    E a resposta é uma lista vazia

  Cenário: Criar um projeto com dados válidos
    Dado que existe um cliente cadastrado
    Quando faço POST em "/projects" com os dados:
      | client_id        | <client_id>    |
      | utility_company  | CEMIG          |
      | utility_protocol | P-001          |
      | customer_class   | B1             |
      | modality         | Micro          |
      | framework        | NET            |
      | unit_control     | UC-001         |
      | project_type     | Residencial    |
    Então o status da resposta é 201
    E a resposta contém "utility_company" com valor "CEMIG"
    E o projeto foi criado com "created_by" do usuário autenticado

  Cenário: Criar projeto com status inicial
    Dado que existe um cliente cadastrado
    Quando faço POST em "/projects" com os dados:
      | client_id        | <client_id>    |
      | utility_company  | CEMIG          |
      | utility_protocol | P-002          |
      | customer_class   | B1             |
      | modality         | Mini           |
      | framework        | NET            |
      | unit_control     | UC-002         |
      | project_type     | Comercial      |
      | status           | em_analise     |
    Então o status da resposta é 201
    E a resposta contém "status" com valor "em_analise"
    E o projeto tem um registro de status "em_analise"

  Cenário: Criar projeto sem cliente resulta em erro
    Quando faço POST em "/projects" com os dados:
      | client_id        | 00000000-0000-0000-0000-000000000000 |
      | utility_company  | CEMIG                                |
      | utility_protocol | P-003                                |
      | customer_class   | B1                                   |
      | modality         | Micro                                |
      | framework        | NET                                  |
      | unit_control     | UC-003                               |
      | project_type     | Residencial                          |
    Então o status da resposta é 422

  Cenário: Buscar um projeto existente
    Dado que existe um projeto cadastrado
    Quando faço GET em "/projects/<project_id>"
    Então o status da resposta é 200
    E a resposta contém "utility_company" com valor "CEMIG"

  Cenário: Buscar projeto inexistente retorna 404
    Quando faço GET em "/projects/00000000-0000-0000-0000-000000000000"
    Então o status da resposta é 404

  Cenário: Atualizar um projeto
    Dado que estou autenticado como administrador
    E que existe um projeto cadastrado
    Quando faço PATCH em "/projects/<project_id>" com os dados:
      | fast_track | true |
    Então o status da resposta é 200

  Cenário: Remover um projeto
    Dado que estou autenticado como administrador
    E que existe um projeto cadastrado
    Quando faço DELETE em "/projects/<project_id>"
    Então o status da resposta é 204
    E o projeto não existe mais no banco
