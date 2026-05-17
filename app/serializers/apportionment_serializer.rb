# frozen_string_literal: true

class ApportionmentSerializer
  def initialize(apportionment)
    @apportionment = apportionment
  end

  def as_json(*)
    {
      id: @apportionment.id,
      service_id: @apportionment.service_id,
      consumer_unit: @apportionment.consumer_unit,
      address: @apportionment.address,
      classification: @apportionment.classification,
      percentage: @apportionment.percentage,
      created_at: @apportionment.created_at,
      updated_at: @apportionment.updated_at
    }
  end
end
