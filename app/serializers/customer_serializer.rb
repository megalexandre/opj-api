# frozen_string_literal: true

class CustomerSerializer
  def initialize(customer)
    @customer = customer
  end

  def as_json(*)
    {
      id: @customer.id,
      name: @customer.name,
      email: @customer.email,
      tax_id: @customer.tax_id,
      phone: @customer.phone,
      address: @customer.address ? AddressSerializer.new(@customer.address).as_json : nil,
      created_at: @customer.created_at,
      updated_at: @customer.updated_at,
      created_by: @customer.created_by,
      updated_by: @customer.updated_by
    }
  end
end
