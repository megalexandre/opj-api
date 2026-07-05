# frozen_string_literal: true

class TechnicalDetailsController < ApplicationController
  before_action :set_project
  before_action -> { authorize_project_participant!(@project) }, only: %i[create update destroy]
  before_action :set_technical_detail, only: %i[show update destroy]

  # GET /projects/1/technical_details
  def index
    technical_details = @project.technical_details.order(created_at: :asc)
    render json: technical_details.map { TechnicalDetailSerializer.new(_1).as_json }
  end

  # GET /projects/1/technical_details/1
  def show
    render json: TechnicalDetailSerializer.new(@technical_detail).as_json
  end

  # POST /projects/1/technical_details
  def create
    technical_detail = @project.technical_details.new(technical_detail_params)

    if technical_detail.save
      render json: TechnicalDetailSerializer.new(technical_detail).as_json, status: :created
    else
      render json: technical_detail.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /projects/1/technical_details/1
  def update
    if @technical_detail.update(technical_detail_params)
      render json: TechnicalDetailSerializer.new(@technical_detail).as_json
    else
      render json: @technical_detail.errors, status: :unprocessable_content
    end
  end

  # DELETE /projects/1/technical_details/1
  def destroy
    @technical_detail.destroy!
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize_view!(@project)
  end

  def set_technical_detail
    @technical_detail = @project.technical_details.find(params.expect(:id))
  end

  def technical_detail_params
    params.permit(:opening_date, :supply_voltage, :new_project, :zero_grid_control,
                  modules: [], inverters: [], entry_standard_items: [], credit_divisions: [])
  end
end
