# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  included do
    before_save   :set_updated_by
    before_create :set_created_by
  end

  private

  def set_created_by
    self.created_by = Current.user&.id
  end

  def set_updated_by
    self.updated_by = Current.user&.id
  end
end
