# frozen_string_literal: true

class ConcessionairesController < ApplicationController
  before_action :set_concessionaire, only: %i[show update destroy]
  before_action -> { authorize!(Concessionaire) }, only: %i[index paginate create]

  # GET /concessionaires/paginate
  def paginate
    @pagy, @concessionaires = pagy(policy_scope(Concessionaire.all))
    render_page @pagy, @concessionaires, serializer: ConcessionaireSerializer
  end

  # GET /concessionaires
  def index
    @concessionaires = policy_scope(Concessionaire.all)

    render json: @concessionaires
  end

  # GET /concessionaires/1
  def show
    render json: @concessionaire
  end

  # POST /concessionaires
  def create
    @concessionaire = Concessionaire.new(concessionaire_params)

    if @concessionaire.save
      render json: @concessionaire, status: :created, location: @concessionaire
    else
      render json: @concessionaire.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /concessionaires/1
  def update
    if @concessionaire.update(concessionaire_params)
      render json: @concessionaire
    else
      render json: @concessionaire.errors, status: :unprocessable_content
    end
  end

  # DELETE /concessionaires/1
  def destroy
    @concessionaire.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_concessionaire
    @concessionaire = Concessionaire.find(params.expect(:id))
    authorize!(@concessionaire)
  end

  # Only allow a list of trusted parameters through.
  def concessionaire_params
    params.permit(:name, :acronym, :code, :region, :phone, :email, :active, :logo)
  end
end
