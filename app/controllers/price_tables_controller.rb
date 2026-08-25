# frozen_string_literal: true

class PriceTablesController < ApplicationController
  before_action :set_price_table, only: %i[show update destroy]

  # GET /price_tables/paginate
  def paginate
    @pagy, @price_tables = pagy(apply_access_scope(scoped_price_tables))
    render_page @pagy, @price_tables, serializer: PriceTableSerializer
  end

  # GET /price_tables
  def index
    @price_tables = apply_access_scope(scoped_price_tables)
    render json: @price_tables.map { PriceTableSerializer.new(_1).as_json }
  end

  # GET /price_tables/1
  def show
    render json: PriceTableSerializer.new(@price_table).as_json
  end

  # POST /price_tables
  def create
    @price_table = PriceTable.new(price_table_params)

    if @price_table.save
      render json: PriceTableSerializer.new(@price_table).as_json, status: :created
    else
      render json: @price_table.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /price_tables/1
  def update
    if @price_table.update(price_table_params)
      render json: PriceTableSerializer.new(@price_table).as_json
    else
      render json: @price_table.errors, status: :unprocessable_content
    end
  end

  # DELETE /price_tables/1
  def destroy
    @price_table.destroy!
  end

  private

  def scoped_price_tables
    params[:kind].present? ? PriceTable.where(kind: params[:kind]) : PriceTable.all
  end

  def set_price_table
    @price_table = PriceTable.find(params.expect(:id))
    authorize_record!(@price_table)
  end

  def price_table_params
    params.permit(
      :kind, :name,
      values: [
        :id, :min, :max, :valor, :classificacao, :tipoLigacao, :nome, :percentual, :ativo,
        { usuariosAutorizados: [] }
      ]
    )
  end
end
