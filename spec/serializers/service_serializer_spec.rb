# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceSerializer do
  subject(:json) { described_class.new(service.reload).as_json }

  let(:service) { create(:service, subsequence: 'A', coordinates: 'POINT(-43.9 -19.9)') }

  before do
    create(:apportionment, service: service)
    create(:service_entry_item, service: service)
  end

  it 'serializes the service attributes' do
    expect(json).to include(id: service.id, service_type: 'Ligação Nova', subsequence: 'A')
  end

  it 'serializes coordinates as latitude/longitude' do
    expect(json[:coordinates]).to eq(latitude: -19.9, longitude: -43.9)
  end

  it 'returns nil coordinates when absent' do
    service.update!(coordinates: nil)
    expect(json[:coordinates]).to be_nil
  end

  it 'embeds apportionments' do
    expect(json[:apportionments]).to contain_exactly(
      include(service_id: service.id, consumer_unit: 'UC-001', percentage: 100)
    )
  end

  it 'embeds service entry items' do
    expect(json[:service_entry_items]).to contain_exactly(
      include(service_id: service.id, connection_type: 'Monofásico', quantity: 1)
    )
  end
end
