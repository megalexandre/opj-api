# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  PROFILES = Permissions::ROLES

  # Older clients still send the pre-RBAC profile name.
  LEGACY_PROFILES = { 'user' => Permissions::INTEGRATOR }.freeze

  before_validation { self.profile = LEGACY_PROFILES.fetch(profile, profile) }

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :name, :email, :profile, presence: true
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :profile, inclusion: { in: PROFILES }

  def admin? = profile == Permissions::ADMIN
  def integrator? = profile == Permissions::INTEGRATOR
end
