# frozen_string_literal: true

class CalendarEventSerializer
  def initialize(calendar_event)
    @calendar_event = calendar_event
  end

  def as_json(*)
    {
      id: @calendar_event.id,
      project_id: @calendar_event.project_id,
      date: @calendar_event.date,
      content: @calendar_event.content,
      created_by: @calendar_event.created_by,
      updated_by: @calendar_event.updated_by,
      created_at: @calendar_event.created_at,
      updated_at: @calendar_event.updated_at
    }
  end
end
