class ForumCategoriesController < ApplicationController
  before_action :admin_only, except: %i[index]
  before_action :load_forum_category, only: %i[edit update destroy]
  respond_to :html, :json

  def index
    @forum_categories = ForumCategory.visible.ordered_categories.paginate(params[:page], limit: 50)
    respond_with(@forum_categories)
  end

  def new
    @forum_category = ForumCategory.new
  end

  def create
    @forum_category = ForumCategory.create(category_params)
    flash[:notice] = @forum_category.valid? ? "Forum category created" : @forum_category.errors.full_messages.join("; ")
    respond_with(@forum_category) do |format|
      format.html { redirect_to forum_categories_path }
    end
  end

  def destroy
    @forum_category.destroy
    flash[:notice] = @forum_category.errors.any? ? @forum_category.errors.full_messages.join("; ") : "Forum category deleted"
    respond_with(@forum_category) do |format|
      format.html { redirect_to forum_categories_path }
    end
  end

  def edit
  end

  def update
    @forum_category.update(category_params)

    flash[:notice] = @forum_category.valid? ? "Category updated" : @forum_category.errors.full_messages.join('; ')
    respond_with(@forum_category) do |format|
      format.html { redirect_to forum_categories_path }
    end
  end

  def reorder
    new_orders = params[:_json].reject { |o| o[:id].nil? }
    new_ids = new_orders.pluck(:id)
    current_ids = ForumCategory.all.select(:id).map(&:id)
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

    if changes != 0
      ModAction.log(:forum_categories_reorder, { total: changes })
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: forum_categories_path) }
      format.json
    end
  end

  private

  def category_params
    params.require(:forum_category).permit(%i[name can_create can_reply can_view order])
  end

  def load_forum_category
    @forum_category = ForumCategory.find(params[:id])
  end
end
