# frozen_string_literal: true

class ProjectSerializer
  def initialize(project)
    @project = project
  end

  def as_json(*)
    {
      id: @project.id,
      client_id: @project.client_id,
      address_id: @project.address_id,
      utility_company: @project.utility_company,
      utility_protocol: @project.utility_protocol,
      customer_class: @project.customer_class,
      integrator: @project.integrator,
      integrator_name: @project.integrator_user&.name,
      modality: @project.modality,
      framework: @project.framework,
      status: @project.status,
      amount: @project.amount,
      dc_protection: @project.dc_protection,
      system_power: @project.system_power,
      unit_control: @project.unit_control,
      description: @project.description,
      project_type: @project.project_type,
      fast_track: @project.fast_track,
      coordinates: serialize_coordinates(@project.coordinates),
      services_names: @project.services_names,
      sequence: @project.sequence,
      subsequence: @project.subsequence,
      related_project_id: @project.related_project_id,
      statuses: serialize_statuses(@project.statuses),
      created_at: @project.created_at,
      updated_at: @project.updated_at,
      created_by: @project.created_by,
      updated_by: @project.updated_by,
      editable: Current.user&.admin?
    }
  end

  private

  def serialize_statuses(statuses)
    statuses.order(created_at: :asc).map do |s|
      {
        id: s.id,
        name: s.name,
        comments: s.comments.map { |c| { id: c.id, body: c.body, created_by: c.created_by, created_at: c.created_at } },
        created_by: s.created_by,
        created_at: s.created_at
      }
    end
  end

  def serialize_coordinates(point)
    return nil if point.nil?

    { latitude: point.y, longitude: point.x }
  end
end
