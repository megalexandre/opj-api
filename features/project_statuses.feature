# language: pt

Funcionalidade: Status de Projetos
  Como um usuário autenticado
  Quero registrar mudanças de status em projetos
  Para manter o histórico completo do ciclo de vida

  Contexto:
    Dado que estou autenticado como administrador
    E que existe um projeto cadastrado

  Cenário: Listar status do projeto
    Dado que o projeto tem 2 status cadastrados
    Quando faço GET em "/projects/<project_id>/statuses"
    Então o status da resposta é 200
    E a resposta contém uma lista com 2 itens

  Cenário: Registrar um novo status no projeto
    Quando faço POST em "/projects/<project_id>/statuses" com os dados:
      | name | aprovado |
    Então o status da resposta é 201
    E a resposta contém "name" com valor "aprovado"
    E o projeto tem um registro de status "aprovado"
    E o status atual do projeto é "aprovado"

  Cenário: Registrar múltiplos status mantém histórico
    Quando faço POST em "/projects/<project_id>/statuses" com os dados:
      | name | em_analise |
    E faço POST em "/projects/<project_id>/statuses" com os dados:
      | name | aprovado |
    Então o status da resposta é 201
    E o projeto tem 2 registros de status
    E o status atual do projeto é "aprovado"

  Cenário: Registrar status com comentário inicial
    Quando faço POST em "/projects/<project_id>/statuses" com os dados:
      | name    | em_analise                      |
      | comment | Aguardando vistoria do engenheiro |
    Então o status da resposta é 201
    E a resposta contém "name" com valor "em_analise"
    E o status criado tem comentário "Aguardando vistoria do engenheiro"

  Cenário: Registrar status sem nome retorna erro
    Quando faço POST em "/projects/<project_id>/statuses" com os dados:
      | name |  |
    Então o status da resposta é 422

  Cenário: Registrar status em projeto inexistente retorna 404
    Quando faço POST em "/projects/00000000-0000-0000-0000-000000000000/statuses" com os dados:
      | name | aprovado |
    Então o status da resposta é 404
