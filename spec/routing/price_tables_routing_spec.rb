# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceTablesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/price_tables').to route_to('price_tables#index')
    end

    it 'routes to #show' do
      expect(get: '/price_tables/1').to route_to('price_tables#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/price_tables').to route_to('price_tables#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/price_tables/1').to route_to('price_tables#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/price_tables/1').to route_to('price_tables#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/price_tables/1').to route_to('price_tables#destroy', id: '1')
    end
  end
end
