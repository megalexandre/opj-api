# frozen_string_literal: true

module Paginatable
  extend ActiveSupport::Concern

  included do
    include Pagy::Backend
  end

  def render_page(pagy, collection, serializer:, **options)
    render json: {
      content: collection.map { serializer.new(_1) },
      totalElements: pagy.count,
      totalPages: pagy.pages,
      size: pagy.limit,
      number: pagy.page - 1,
      numberOfElements: pagy.in,
      first: pagy.prev.nil?,
      last: pagy.next.nil?,
      empty: pagy.count.zero?
    }, **options
  end
end
