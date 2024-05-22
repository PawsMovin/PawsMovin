# frozen_string_literal: true

class ForumCategoriesController < ApplicationController
  before_action :load_forum_category, only: %i[edit update destroy]
  respond_to :html, :json

  def index
    @forum_categories = authorize(ForumCategory).visible.ordered_categories.paginate(params[:page], limit: params[:limit] || 50)
    respond_with(@forum_categories)
  end

  def new
    @forum_category = authorize(ForumCategory.new(permitted_attributes(ForumCategory)))
  end

  def edit
    authorize(@forum_category)
  end

  def create
    @forum_category = authorize(ForumCategory.new(permitted_attributes(ForumCategory)))
    @forum_category.save
    notice(@forum_category.valid? ? "Forum category created" : @forum_category.errors.full_messages.join("; "))
    respond_with(@forum_category) do |format|
      format.html { redirect_to(forum_categories_path) }
    end
  end

  def update
    authorize(@forum_category).update(permitted_attributes(ForumCategory))

    notice(@forum_category.valid? ? "Category updated" : @forum_category.errors.full_messages.join("; "))
    respond_with(@forum_category, location: forum_categories_path)
  end

  def destroy
    authorize(@forum_category).destroy
    notice(@forum_category.errors.any? ? @forum_category.errors.full_messages.join("; ") : "Forum category deleted")
    respond_with(@forum_category, location: forum_categories_path)
  end

  def reorder
    authorize(ForumCategory)
    new_orders = params[:_json].reject { |o| o[:id].nil? }
    new_ids = new_orders.pluck(:id)
    current_ids = ForumCategory.pluck(:id)
    missing = current_ids - new_ids
    extra = new_ids - current_ids
    duplicate = new_ids.select { |id| new_ids.count(id) > 1 }.uniq

    return render_expected_error(400, "Missing ids: #{missing.join(', ')}") if missing.any?
    return render_expected_error(400, "Extra ids provided: #{extra.join(', ')}") if extra.any?
    return render_expected_error(400, "Duplicate ids provided: #{duplicate.join(', ')}") if duplicate.any?

    changes = 0
    ForumCategory.transaction do
      new_orders.each do |order|
        rec = ForumCategory.find(order[:id])
        if rec.order != order[:order]
          rec.update_column(:order, order[:order])
          changes += 1
        end
      end
    end

    ForumCategory.log_reorder(changes) if changes != 0

    respond_to do |format|
      format.html do
        notice("Order updated")
        redirect_back(fallback_location: forum_categories_path)
      end
      format.json
    end
  rescue ActiveRecord::RecordNotFound
    render_expected_error(400, "Category not found")
  end

  private

  def load_forum_category
    @forum_category = ForumCategory.find(params[:id])
  end
end
