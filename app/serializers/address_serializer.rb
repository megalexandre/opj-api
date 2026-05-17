# frozen_string_literal: true

class AddressSerializer
  def initialize(address)
    @address = address
  end

  def as_json(*)
    {
      id: @address.id,
      link: @address.link,
      place: @address.place,
      cep: @address.cep,
      number: @address.number,
      address: @address.address,
      complement: @address.complement,
      neighborhood: @address.neighborhood,
      city: @address.city,
      state: @address.state,
      created_at: @address.created_at,
      updated_at: @address.updated_at,
      created_by: @address.created_by,
      updated_by: @address.updated_by
    }
  end
end
