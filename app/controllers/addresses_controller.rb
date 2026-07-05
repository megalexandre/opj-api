# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :set_address, only: %i[show update destroy]

  # GET /addresses/paginate
  def paginate
    @pagy, @addresses = pagy(apply_access_scope(Address.all))
    render_page @pagy, @addresses, serializer: AddressSerializer
  end

  # GET /addresses
  def index
    @addresses = apply_access_scope(Address.all)
    render json: @addresses.map { AddressSerializer.new(_1) }
  end

  # GET /addresses/1
  def show
    render json: AddressSerializer.new(@address)
  end

  # POST /addresses
  def create
    @address = Address.new(address_params)

    if @address.save
      render json: AddressSerializer.new(@address), status: :created
    else
      render json: @address.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /addresses/1
  def update
    if @address.update(address_params)
      render json: AddressSerializer.new(@address)
    else
      render json: @address.errors, status: :unprocessable_content
    end
  end

  # DELETE /addresses/1
  def destroy
    if @address.destroy
      head :no_content
    else
      render json: { errors: @address.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_address
    @address = Address.find(params.expect(:id))
    #authorize_record!(@address)
  end

  # Only allow a list of trusted parameters through.
  def address_params
    params.permit(:link, :place, :cep, :number, :address, :complement, :neighborhood, :city, :state)
  end
end
