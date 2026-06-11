### Build e push

```bash
docker build -t alexandreqrz/opjapi:latest . &&
docker push alexandreqrz/opjapi:latest
```


# OPJ API

API REST para gerenciamento de projetos de conexão elétrica — clientes, concessionárias, serviços, rateios e uploads de arquivos.

Construída com **Ruby on Rails 8.1** (API-only), **PostgreSQL + PostGIS** e autenticação via **JWT**.

---

## Stack

| Camada | Tecnologia |
|---|---|
| Runtime | Ruby 3.2.3 / Rails 8.1 |
| Banco de dados | PostgreSQL 17 + PostGIS 3.6 |
| Armazenamento de arquivos | MinIO (compatível S3) |
| Autenticação | JWT (24h de validade) |
| Documentação | Swagger UI (`/api-docs`) |
| Servidor | Puma + Thruster |

---

## Recursos da API

| Recurso | Rota base | Descrição |
|---|---|---|
| Auth | `/auth` | Registro, login e perfil |
| Addresses | `/addresses` | Endereços |
| Customers | `/customers` | Clientes |
| Concessionaires | `/concessionaires` | Concessionárias |
| Projects | `/projects` | Projetos |
| Services | `/services` | Serviços (com rateios e itens de entrada) |
| Uploads | `/uploads` | Arquivos vinculados a qualquer entidade |

Todos os endpoints protegidos exigem o header `Authorization: Bearer <token>`.

---

## Rodando localmente

### Pré-requisitos

- Ruby 3.2.3
- PostgreSQL com extensão PostGIS
- MinIO (ou qualquer storage compatível com S3)

### Setup

```bash
bundle install
rails db:create db:migrate
rails server -b 0.0.0.0
```

### Variáveis de ambiente

| Variável | Padrão | Descrição |
|---|---|---|
| `DB_HOST` | `localhost` | Host do PostgreSQL |
| `JWT_SECRET_KEY` | `secret_key_base` | Chave de assinatura JWT |
| `AWS_S3_ENDPOINT` | `http://localhost:9000` | Endpoint MinIO/S3 |
| `AWS_S3_ACCESS_KEY` | `test` | Access key |
| `AWS_S3_SECRET_KEY` | `test` | Secret key |
| `AWS_S3_BUCKET_NAME` | `deploy-board-uploads` | Nome do bucket |

---

## Docker


```

### Subir tudo com docker-compose

```bash
docker compose up --build
```

Sobe os serviços: **app** (porta 3000), **db** (PostgreSQL + PostGIS) e **minio** (porta 9000 / console 9001).
O banco é criado e migrado automaticamente na primeira inicialização.

---

## Desenvolvimento

### Migrations

```bash
rails db:migrate
rails db:migrate:status

# ambiente de test
RAILS_ENV=test rails db:migrate
```

### Gerar scaffold de controller

```bash
bin/rails g scaffold_controller NomeDoRecurso campo1:tipo campo2:tipo
```

Exemplo:

```bash
bin/rails g scaffold_controller Users name:string 
```

### Gerar/atualizar a documentação Swagger

Execute após criar ou alterar specs em `spec/requests/`:

```bash
RAILS_ENV=test bundle exec rails rswag:specs:swaggerize
```

A documentação interativa fica disponível em [`/api-docs`](http://localhost:3000/api-docs).

---

## Testes

```bash
bundle exec rspec
```
