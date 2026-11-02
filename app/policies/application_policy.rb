# frozen_string_literal: true

# Base policy. `record` may be a model instance or a model class (for
# collection-level actions such as index/create).
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def self.for(user, record)
    klass = record.is_a?(Class) ? record : record.class
    "#{klass.name}Policy".safe_constantize&.new(user, record) || new(user, record)
  end

  def allowed?(action)
    case Permissions.rule(user.profile, resource, action)
    when :any then true
    when :own then record.is_a?(Class) || owner?
    else false
    end
  end

  # Whether the record falls inside the user's scope. Delegating to Scope keeps
  # a single definition of "who sees what".
  def visible?
    return true if record.is_a?(Class)

    self.class::Scope.new(user, record.class.all).resolve.exists?(record.id)
  end

  private

  def resource
    model_class.model_name.singular.to_sym
  end

  def model_class
    record.is_a?(Class) ? record : record.class
  end

  def owner?
    record.created_by == user.id
  end

  class Scope
    attr_reader :user, :relation

    def initialize(user, relation)
      @user = user
      @relation = relation
    end

    def self.for(user, relation)
      "#{relation.model.name}Policy::Scope".safe_constantize&.new(user, relation) || new(user, relation)
    end

    def resolve
      return relation if user.admin?

      relation.where(created_by: user.id)
    end

    private

    def visible_project_ids
      Project.visible_to(user).select(:id)
    end

    def visible_service_ids
      Service.visible_to(user).select(:id)
    end
  end
end
