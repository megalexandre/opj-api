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

## Observabilidade

A API expõe métricas Prometheus (gems `yabeda-*`) em **`:9394/metrics`**, num servidor separado subido pelo Puma. A porta pública (80/3000) não serve `/metrics`. Para trocar a porta, use `PROMETHEUS_EXPORTER_PORT`.

| Grupo | Métricas |
|---|---|
| HTTP | `rails_requests_total`, `rails_request_duration_seconds` (por controller/action/status) |
| Puma | `puma_busy_threads`, `puma_backlog`, `puma_max_threads` |
| Banco | `activerecord_connection_pool_*`, `activerecord_query_duration_seconds` |
| Jobs | `activejob_*` |
| Ruby | `gc_*` |
| Negócio | `opj_projects{status}`, `opj_customers`, `opj_uploads`, `opj_uploads_bytes`, `opj_ledger_amount_cents` (calculadas a cada scrape em `config/initializers/yabeda.rb`) |

```bash
bin/rails s && curl localhost:9394/metrics
```

### Prometheus + Grafana no Coolify

Em produção: **https://grafana.projetosopjengenharia.com.br** (usuário `admin`, senha em `SERVICE_PASSWORD_GRAFANA` no Coolify).

A pasta [`monitoring/`](monitoring/) tem dois arquivos:

- `docker-compose.yml`: Prometheus + Grafana, com a config do Prometheus, o datasource e o dashboard **OPJ API** embutidos via `content:` (extensão do Coolify).
- `opj-api-endpoints.json`: o dashboard **OPJ API – Endpoints** (latência e erros por rota). Ele usa `$__range`, que o compose interpretaria como variável, por isso não vai embutido. Importe em *Dashboards → New → Import*, na pasta **OPJ**.

Para subir ou atualizar:

1. No Coolify, use **+ New → Docker Compose Empty** (ou, num stack existente, **Edit Compose File**) e cole `monitoring/docker-compose.yml`.
2. Ative **Connect to Predefined Network**, para o Prometheus entrar na rede `coolify`, a mesma da API.
3. Configure o domínio do serviço `grafana` com a porta interna: `https://grafana.projetosopjengenharia.com.br:3000`.
4. Não publique a porta 9394 da API. O Prometheus acessa a API pela rede interna.

Os dados ficam nos volumes `prometheus-data` (30 dias) e `grafana-data`, que sobrevivem a redeploys.

O Prometheus descobre o container da API pelo socket do Docker, filtrando pela imagem `alexandreqrz/opjapi:latest`, porque o Coolify troca o nome do container a cada deploy. Se a API passar a usar outra tag, ajuste o filtro no `prometheus.yml` embutido no compose.

> Com `WEB_CONCURRENCY` > 1 (Puma em cluster), cada worker tem as próprias métricas em memória. Nesse caso, configure o `Prometheus::Client::DataStores::DirectFileStore` para agregar entre workers. Jobs executados pelo supervisor do Solid Queue rodam em processos separados, então só as métricas de enfileiramento aparecem.

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
