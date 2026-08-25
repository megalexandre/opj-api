# frozen_string_literal: true

class PriceTable < ApplicationRecord
  include Auditable

  KINDS = %w[fotovoltaico padrao_entrada cupom_projeto cupom_servico].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :name, presence: true
end
