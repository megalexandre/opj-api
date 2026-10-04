# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Yabeda business metrics' do
  def gauge_value(gauge, tags = {})
    gauge.get(tags)
  end

  it 'collects project counts by status, ignoring soft-deleted projects' do
    create_list(:project, 2, status: 'pendente')
    create(:project, status: 'aprovado')
    create(:project, status: 'aprovado', deleted_at: Time.current)

    Yabeda.collect!

    expect(gauge_value(Yabeda.opj.projects, { status: 'pendente' })).to eq(2)
    expect(gauge_value(Yabeda.opj.projects, { status: 'aprovado' })).to eq(1)
  end

  it 'collects customer, upload and ledger totals' do
    create_list(:customer, 3)
    create(:upload, size: 1000)
    create(:upload, size: 500)
    create(:ledger, amount_cents: 1500)
    create(:ledger, amount_cents: -200)

    Yabeda.collect!

    expect(gauge_value(Yabeda.opj.customers)).to eq(Customer.count)
    expect(gauge_value(Yabeda.opj.uploads)).to eq(2)
    expect(gauge_value(Yabeda.opj.uploads_bytes)).to eq(1500)
    expect(gauge_value(Yabeda.opj.ledger_amount_cents)).to eq(1300)
  end
end
