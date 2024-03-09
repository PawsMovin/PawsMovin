# frozen_string_literal: true

module Rules
  class QuickController < ApplicationController
    before_action :admin_only
    respond_to :html

    def index
      @quick = QuickRule.order(:order)
    end

    def new
      @quick = QuickRule.new
      @rules = Rule.joins(:category).order("rule_categories.order, rules.order")
    end

    def edit
      @quick = QuickRule.find(params[:id])
      @rules = Rule.joins(:category).order("rule_categories.order, rules.order")
    end

    def create
      @quick = QuickRule.create(quick_params)
      @rules = Rule.joins(:category).order("rule_categories.order, rules.order")
      notice(@quick.errors.any? ? @quick.errors.full_messages.join(", ") : "Quick rule created")
      respond_with(@quick, location: quick_rules_path)
    end

    def update
      @quick = QuickRule.find(params[:id])
      @rules = Rule.joins(:category).order("rule_categories.order, rules.order")
      @quick.update(quick_params)
      notice(@quick.errors.any? ? @quick.errors.full_messages.join(", ") : "Quick rule updated")
      respond_with(@quick, location: quick_rules_path)
    end

    def destroy
      @quick = QuickRule.find(params[:id])
      @quick.destroy
      notice("Quick rule deleted")
      respond_with(@quick, location: quick_rules_path)
    end

    def order
      @quick = QuickRule.order(:order)
      respond_with(@quick)
    end

    def reorder
      return render_expected_error(422, "Error: No quick rules provided") unless params[:_json].is_a?(Array) && params[:_json].any?
      changes = 0
      QuickRule.transaction do
        params[:_json].each do |data|
          quick = QuickRule.find(data[:id])
          quick.update_attribute(:order, data[:order])
          changes += 1 if quick.previous_changes.any?
        end

        list = QuickRule.all
        if list.any? { |quick| !quick.valid? }
          errors = []
          list.each do |quick|
            errors << { id: quick.id, name: quick.name, message: quick.errors.full_messages.join("; ") } if !quick.valid? && quick.errors.any?
          end
          render(json: { success: false, errors: errors }, status: 422)
          raise(ActiveRecord::Rollback)
        else
          QuickRule.log_reorder(changes) if changes != 0
          respond_to do |format|
            format.json { head(204) }
            format.js do
              render(json: { html: render_to_string(partial: "rules/quick/sort", locals: { list: QuickRule.order(:order) }) })
            end
          end
        end
      end
    rescue ActiveRecord::RecordNotFound
      render_expected_error(422, "Error: Category not found")
    end

    private

    def quick_params
      params.require(:quick_rule).permit(:header, :reason, :rule_id)
    end
  end
end
