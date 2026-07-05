# language: pt

Funcionalidade: Gerenciamento de Concessionárias

  Como um usuário autenticado
  Quero gerenciar concessionárias
  Para associá-las aos serviços de energia solar

  Contexto:
    Dado que estou autenticado como usuário

  Cenário: Listar concessionárias quando não há nenhuma
    Quando faço GET em "/concessionaires"
    Então o status da resposta é 200
    E a resposta é uma lista vazia

  Cenário: Listar concessionárias existentes
    Dado que existe uma concessionária cadastrada
    Quando faço GET em "/concessionaires"
    Então o status da resposta é 200
    E a resposta contém uma lista com 1 itens

  Cenário: Criar concessionária com dados válidos
    Quando faço POST em "/concessionaires" com os dados:
      | name   | CEMIG              |
      | acronym | CEM               |
      | code   | C001               |
      | region | Sudeste            |
      | phone  | 3133334444         |
      | email  | contato@cemig.com  |
      | active | true               |
    Então o status da resposta é 201
    E a resposta contém "name" com valor "CEMIG"
    E a concessionária foi criada no banco

  Cenário: Criar concessionária com logo em base64
    Quando faço POST em "/concessionaires" com logo em base64
    Então o status da resposta é 201
    E a resposta contém um logo comprimido

  Cenário: Criar concessionária sem nome resulta em erro
    Quando faço POST em "/concessionaires" com os dados:
      | active | true |
    Então o status da resposta é 422

  Cenário: Buscar concessionária existente
    Dado que existe uma concessionária cadastrada
    Quando faço GET em "/concessionaires/<concessionaire_id>"
    Então o status da resposta é 200
    E a resposta contém "name" com valor "CEMIG"

  Cenário: Buscar concessionária inexistente retorna 404
    Quando faço GET em "/concessionaires/00000000-0000-0000-0000-000000000000"
    Então o status da resposta é 404

  Cenário: Atualizar concessionária
    Dado que existe uma concessionária cadastrada
    Quando faço PATCH em "/concessionaires/<concessionaire_id>" com os dados:
      | name | COPEL |
    Então o status da resposta é 200
    E a resposta contém "name" com valor "COPEL"

  Cenário: Atualizar logo da concessionária
    Dado que existe uma concessionária cadastrada
    Quando faço PATCH em "/concessionaires/<concessionaire_id>" com logo em base64
    Então o status da resposta é 200
    E a resposta contém um logo comprimido

  Cenário: Remover concessionária
    Dado que existe uma concessionária cadastrada
    Quando faço DELETE em "/concessionaires/<concessionaire_id>"
    Então o status da resposta é 204
    E a concessionária não existe mais no banco
