# frozen_string_literal: true

class ProjectStatusCommentsController < ApplicationController
  before_action :set_status

  def create
    comment = @status.comments.create!(
      body: comment_params[:body],
      created_by: current_user.id
    )

    render json: serialize(comment), status: :created
  end

  def update
    comment = @status.comments.find(params[:id])
    comment.update!(body: comment_params[:body])

    render json: serialize(comment)
  end

  def destroy
    comment = @status.comments.find(params[:id])
    comment.destroy!

    head :no_content
  end

  private

  def set_status
    project = Project.find(params[:project_id])
    authorize_record!(project)
    @status = project.statuses.find(params[:status_id])
  end

  def comment_params
    params.permit(:body)
  end

  def serialize(comment)
    {
      id: comment.id,
      body: comment.body,
      status_id: comment.project_status_id,
      created_by: comment.created_by,
      created_at: comment.created_at,
      updated_at: comment.updated_at
    }
  end
end
