# frozen_string_literal: true

class TechnicalDetailSerializer
  def initialize(technical_detail)
    @technical_detail = technical_detail
  end

  def as_json(*)
    {
      id: @technical_detail.id,
      project_id: @technical_detail.project_id,
      opening_date: @technical_detail.opening_date,
      supply_voltage: @technical_detail.supply_voltage,
      new_project: @technical_detail.new_project,
      zero_grid_control: @technical_detail.zero_grid_control,
      modules: @technical_detail.modules,
      inverters: @technical_detail.inverters,
      entry_standard_items: @technical_detail.entry_standard_items,
      credit_divisions: @technical_detail.credit_divisions,
      created_at: @technical_detail.created_at,
      updated_at: @technical_detail.updated_at,
      created_by: @technical_detail.created_by,
      updated_by: @technical_detail.updated_by
    }
  end
end
