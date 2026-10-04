# frozen_string_literal: true

# Métricas Prometheus. As métricas técnicas (requisições, Puma, ActiveRecord, GC)
# vêm das gems yabeda-*; aqui ficam as de jobs e as de negócio. O exporter é
# servido pelo plugin :yabeda_prometheus do Puma em :9394/metrics (ver
# config/puma.rb), fora da porta pública da API.
Yabeda::ActiveJob.install!

Yabeda.configure do
  group :opj do
    gauge :projects, tags: %i[status], comment: 'Projetos ativos (não excluídos) por status'
    gauge :customers, comment: 'Total de clientes cadastrados'
    gauge :uploads, comment: 'Total de arquivos enviados'
    gauge :uploads_bytes, comment: 'Soma do tamanho dos arquivos enviados, em bytes'
    gauge :ledger_amount_cents, comment: 'Soma dos lançamentos financeiros, em centavos'
  end

  # Roda a cada scrape, na thread do exporter: por isso pega a própria conexão do pool.
  collect do
    ActiveRecord::Base.connection_pool.with_connection do
      Project.group(:status).count.each do |status, total|
        Yabeda.opj.projects.set({ status: status.presence || 'sem_status' }, total)
      end
      Yabeda.opj.customers.set({}, Customer.count)
      Yabeda.opj.uploads.set({}, Upload.count)
      Yabeda.opj.uploads_bytes.set({}, Upload.sum(:size))
      Yabeda.opj.ledger_amount_cents.set({}, Ledger.sum(:amount_cents))
    end
  end
end
