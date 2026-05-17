# frozen_string_literal: true

class ServicesController < ApplicationController
  before_action :set_service, only: %i[show update destroy]

  # GET /services/paginate
  def paginate
    @pagy, @services = pagy(apply_access_scope(Service.includes(:apportionments, :service_entry_items).all))
    render_page @pagy, @services, serializer: ServiceSerializer
  end

  # GET /services
  def index
    @services = apply_access_scope(Service.includes(:apportionments, :service_entry_items).all)
    render json: @services.map { ServiceSerializer.new(_1).as_json }
  end

  # GET /services/1
  def show
    render json: ServiceSerializer.new(@service).as_json
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    if @service.save
      render json: ServiceSerializer.new(@service).as_json, status: :created
    else
      render json: @service.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /services/1
  def update
    if @service.update(service_params)
      render json: ServiceSerializer.new(@service).as_json
    else
      render json: @service.errors, status: :unprocessable_content
    end
  end

  # DELETE /services/1
  def destroy
    @service.destroy!
  end

  private

  def set_service
    @service = Service.includes(:apportionments, :service_entry_items).find(params.expect(:id))
    authorize_record!(@service)
  end

  def service_params
    params.permit(
      :service_type, :customer_id, :concessionaire_id, :opening_date, :amount,
      :discount_coupon_percentage, :observations, :supply_voltage, :coordinates,
      :generating_consumer_unit, :pole_distance_over_30m,
      :construction_address_id, :generating_address_id,
      apportionments_attributes: %i[
        id consumer_unit address classification percentage _destroy
      ],
      service_entry_items_attributes: %i[
        id connection_type classification quantity circuit_breaker _destroy
      ]
    )
  end
end
