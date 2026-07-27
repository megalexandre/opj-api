# frozen_string_literal: true

class CalendarEventsController < ApplicationController
  before_action :set_calendar_event, only: %i[show update destroy]

  # GET /calendar_events?from=2026-07-01&to=2026-07-31
  def index
    calendar_events = filter_by_date_range(apply_access_scope(CalendarEvent.all)).order(date: :asc)
    render json: calendar_events.map { CalendarEventSerializer.new(_1).as_json }
  end

  # GET /calendar_events/1
  def show
    render json: CalendarEventSerializer.new(@calendar_event).as_json
  end

  # POST /calendar_events
  def create
    @calendar_event = CalendarEvent.new(calendar_event_params)

    if @calendar_event.save
      render json: CalendarEventSerializer.new(@calendar_event).as_json, status: :created
    else
      render json: @calendar_event.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /calendar_events/1
  def update
    if @calendar_event.update(calendar_event_params)
      render json: CalendarEventSerializer.new(@calendar_event).as_json
    else
      render json: @calendar_event.errors, status: :unprocessable_content
    end
  end

  # DELETE /calendar_events/1
  def destroy
    @calendar_event.destroy!
  end

  private

  def set_calendar_event
    @calendar_event = CalendarEvent.find(params.expect(:id))
    authorize_record!(@calendar_event)
  end

  def filter_by_date_range(scope)
    scope = scope.where('date >= ?', params[:from]) if params[:from].present?
    scope = scope.where('date <= ?', params[:to])   if params[:to].present?
    scope
  end

  def calendar_event_params
    params.permit(:date, :project_id, content: {})
  end
end
