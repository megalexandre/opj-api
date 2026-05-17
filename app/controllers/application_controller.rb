# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Paginatable
  include Authenticatable
  include Authorizable

  rescue_from StandardError do |e|
    render json: { message: e.message }, status: :internal_server_error
  end

  rescue_from ActionDispatch::Http::Parameters::ParseError do
    render json: { message: 'Invalid JSON body' }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { message: e.message, errors: e.record.errors }, status: :unprocessable_content
  end

  rescue_from ActiveRecord::InvalidForeignKey do |_|
    render json: { message: 'Invalid reference: associated record not found' }, status: :unprocessable_content
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message }, status: :not_found
  end
end
