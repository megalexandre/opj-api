# frozen_string_literal: true

class ProjectStatusesController < ApplicationController
  before_action :set_project
  before_action :authorize_main!, only: :create

  def index
    statuses = @project.statuses.includes(:comments).order(created_at: :asc)
    render json: statuses.map { |s| serialize(s) }
  end

  def create
    ActiveRecord::Base.transaction do
      status = @project.statuses.create!(
        name: status_params[:name],
        created_by: current_user.id
      )

      if status_params[:comment].present?
        status.comments.create!(
          body: status_params[:comment],
          created_by: current_user.id
        )
      end

      render json: serialize(status), status: :created
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize_view!(@project)
  end

  def status_params
    params.permit(:name, :comment)
  end

  def serialize(status)
    {
      id: status.id,
      name: status.name,
      project_id: @project.id,
      comments: status.comments.map do |c|
        { id: c.id, body: c.body, created_by: c.created_by, created_at: c.created_at }
      end,
      created_by: status.created_by,
      created_at: status.created_at
    }
  end
end
