# frozen_string_literal: true

class LedgersController < ApplicationController
  before_action :set_ledger, only: %i[show update destroy]

  # GET /ledgers/paginate
  def paginate
    @pagy, @ledgers = pagy(apply_access_scope(filtered_ledgers))
    render_page @pagy, @ledgers, serializer: LedgerSerializer
  end

  # GET /ledgers
  def index
    @ledgers = apply_access_scope(Ledger.all)
    render json: @ledgers.map { LedgerSerializer.new(_1).as_json }
  end

  # GET /ledgers/1
  def show
    render json: LedgerSerializer.new(@ledger).as_json
  end

  # POST /ledgers
  def create
    @ledger = Ledger.new(ledger_params)

    if @ledger.save
      render json: LedgerSerializer.new(@ledger).as_json, status: :created
    else
      render json: @ledger.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /ledgers/1
  def update
    if @ledger.update(ledger_params)
      render json: LedgerSerializer.new(@ledger).as_json
    else
      render json: @ledger.errors, status: :unprocessable_content
    end
  end

  # DELETE /ledgers/1
  def destroy
    @ledger.destroy!
  end

  private

  def set_ledger
    @ledger = Ledger.find(params.expect(:id))
    authorize_record!(@ledger)
  end

  def filtered_ledgers
    filter_by_date_range(filter_by_attributes(Ledger.all)).order(created_at: :desc)
  end

  def filter_by_attributes(scope)
    %i[project_id service_id reason].reduce(scope) do |s, attr|
      params[attr].present? ? s.where(attr => params[attr]) : s
    end
  end

  def filter_by_date_range(scope)
    scope = scope.where('created_at >= ?', params[:from]) if params[:from].present?
    scope = scope.where('created_at <= ?', params[:to])   if params[:to].present?
    scope
  end

  def ledger_params
    params.permit(:project_id, :service_id, :amount, :reason, :description)
  end
end
