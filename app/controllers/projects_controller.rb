# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show update destroy inactivate]
  before_action :authorize_main!, only: %i[update destroy inactivate]

  # GET /projects
  def index
    @projects = Project.includes(:integrator_user, statuses: :comments).visible_to(current_user)

    render json: @projects.map { |p| ProjectSerializer.new(p).as_json }
  end

  # GET /projects/1
  def show
    render json: ProjectSerializer.new(@project).as_json
  end

  # POST /projects
  def create
    @project = ProjectCreate.new(params: create_params, current_user: current_user).call
    render json: ProjectSerializer.new(@project).as_json, status: :created, location: @project
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(update_params)
      render json: ProjectSerializer.new(@project).as_json
    else
      render json: @project.errors, status: :unprocessable_content
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy!
  end

  # PATCH /projects/1/inactivate
  def inactivate
    @project.update!(deleted_at: Time.current)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.includes(:client, statuses: :comments).find(params.expect(:id))
    authorize_view!(@project)
  end

  def create_params
    params.permit(:client_id, :address_id, :utility_company, :utility_protocol, :secondary_protocol,
                  :customer_class, :integrator, :modality, :framework, :status, :amount, :dc_protection,
                  :system_power, :unit_control, :description, :project_type, :fast_track,
                  :coordinates, :sequence, :subsequence, :related_project_id, services_names: [])
  end

  def update_params
    params.permit(:client_id, :address_id, :utility_company, :utility_protocol, :secondary_protocol,
                  :customer_class, :integrator, :modality, :framework, :amount, :dc_protection,
                  :system_power, :unit_control, :description, :project_type, :fast_track,
                  :coordinates, :sequence, :subsequence, :related_project_id, services_names: [])
  end
end
