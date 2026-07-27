# frozen_string_literal: true

# Quando a API é servida atrás de um proxy reverso que remove um prefixo de path
# (ex.: Traefik com StripPrefix em /api/v2), o Rails só enxerga o path já sem o
# prefixo. Isso quebra qualquer resposta que monte URLs a partir de SCRIPT_NAME
# (como o redirect de /api-docs para /api-docs/index.html do rswag-ui), pois o
# navegador recebe uma URL sem o prefixo e o proxy não sabe mais rotear de volta
# para esta aplicação.
relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']

if relative_url_root.present?
  # require direto: neste ponto do boot o autoloader do Zeitwerk ainda não
  # está ativo, então referenciar a constante da middleware sem isso levanta
  # NameError.
  require Rails.root.join('app/middleware/relative_url_root_middleware')

  Rails.application.config.relative_url_root = relative_url_root
  Rails.application.config.middleware.insert_before 0, RelativeUrlRootMiddleware, relative_url_root
end
