# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    index?
  end

  def search?
    index?
  end

  def new?
    create?
  end

  def create?
    unbanned?
  end

  def edit?
    update?
  end

  def update?
    unbanned?
  end

  def delete?
    destroy?
  end

  def destroy?
    unbanned?
  end

  def unbanned?
    user.is_member? && !user.is_banned?
  end

  def logged_in?
    !user.is_anonymous?
  end

  def approver?
    user.is_approver?
  end

  def can_search_ip_addr?
    user.is_admin?
  end

  def can_see_ip_addr?
    user.is_admin?
  end

  def can_see_email?
    user.is_admin?
  end

  def all?(*methods)
    methods.all? { |name| respond_to?(name) ? send(name) : false }
  end

  def any?(*methods)
    methods.any? { |name| respond_to?(name) ? send(name) : false }
  end

  def policy(object)
    Pundit.policy!(user, object)
  end

  def permitted_attributes
    []
  end

  def permitted_attributes_for_create
    permitted_attributes
  end

  def permitted_attributes_for_update
    permitted_attributes
  end

  def permitted_attributes_for_new
    permitted_attributes_for_create
  end

  def permitted_attributes_for_edit
    permitted_attributes_for_update
  end

  def can_use_attribute?(attr, action = nil)
    attr = [attr] unless attr.is_a?(Array)
    permitted = action.nil? || !respond_to?("permitted_attributes_for_#{action}") ? permitted_attributes : send("permitted_attributes_for_#{action}")
    (permitted & attr) == attr
  end

  alias can_use_attributes? can_use_attribute?

  def can_use_any_attribute?(*attrs, action: nil)
    attrs.any? { |attr| can_use_attribute?(attr, action) }
  end

  def can_search_attribute?(attr)
    attr = [attr] unless attr.is_a?(Array)
    (permitted_search_params & attr) == attr
  end

  alias can_search_attributes? can_search_attribute?

  def visible_for_search(relation, _attribute = nil)
    relation
  end

  def api_attributes
    record.class.column_names.map(&:to_sym)
  end

  def permitted_search_params
    %i[id created_at updated_at order]
  end
end
