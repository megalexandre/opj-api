# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :name, :email, :profile, presence: true
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
