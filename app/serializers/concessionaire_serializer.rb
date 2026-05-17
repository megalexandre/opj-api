# frozen_string_literal: true

class ConcessionaireSerializer
  def initialize(concessionaire)
    @concessionaire = concessionaire
  end

  def as_json(*)
    {
      id: @concessionaire.id,
      name: @concessionaire.name,
      acronym: @concessionaire.acronym,
      code: @concessionaire.code,
      region: @concessionaire.region,
      phone: @concessionaire.phone,
      email: @concessionaire.email,
      active: @concessionaire.active,
      logo: @concessionaire.logo,
      created_at: @concessionaire.created_at,
      updated_at: @concessionaire.updated_at,
      created_by: @concessionaire.created_by,
      updated_by: @concessionaire.updated_by
    }
  end
end
