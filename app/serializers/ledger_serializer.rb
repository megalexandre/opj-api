# frozen_string_literal: true

class LedgerSerializer
  def initialize(ledger)
    @ledger = ledger
  end

  def as_json(*)
    {
      id: @ledger.id,
      project_id: @ledger.project_id,
      service_id: @ledger.service_id,
      amount: @ledger.amount.format,
      amount_cents: @ledger.amount_cents,
      reason: @ledger.reason,
      description: @ledger.description,
      paid_at: @ledger.paid_at,
      created_at: @ledger.created_at,
      updated_at: @ledger.updated_at
    }
  end
end
