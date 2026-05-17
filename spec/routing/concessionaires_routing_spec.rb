# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConcessionairesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/concessionaires').to route_to('concessionaires#index')
    end

    it 'routes to #show' do
      expect(get: '/concessionaires/1').to route_to('concessionaires#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/concessionaires').to route_to('concessionaires#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/concessionaires/1').to route_to('concessionaires#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/concessionaires/1').to route_to('concessionaires#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/concessionaires/1').to route_to('concessionaires#destroy', id: '1')
    end
  end
end
