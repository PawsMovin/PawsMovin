# frozen_string_literal: true

module Admin
  class StaffNotesController < ApplicationController
    before_action :load_staff_note, only: %i[update destroy]
    respond_to :html

    def index
      @user = User.find_by(id: params[:user_id])
      @notes = authorize(StaffNote).search(search_params(StaffNote).merge({ user_id: params[:user_id] })).includes(:user, :creator).paginate(params[:page])
      respond_with(@notes)
    end

    def new
      @user = User.find(params[:user_id])
      @staff_note = authorize(StaffNote.new(permitted_attributes(StaffNote)))
      respond_with(@note)
    end

    def create
      @user = User.find(params[:user_id])
      @staff_note = authorize(StaffNote.new(permitted_attributes(StaffNote).merge({ user_id: @user.id })))
      @staff_note.save
      flash[:notice] = @staff_note.valid? ? "Staff Note added" : @staff_note.errors.full_messages.join("; ")
      respond_with(@staff_note) do |format|
        format.html do
          redirect_back(fallback_location: admin_staff_notes_path)
        end
      end
    end

    def update
      authorize(@staff_note).update(permitted_attributes(@staff_note))
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    def destroy
      authorize(@staff_note).update(is_deleted: true)
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    def undelete
      @staff_note = authorize(StaffNote.find(params[:staff_note_id]))
      @staff_note.update(is_deleted: false)
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    private

    def load_staff_note
      @staff_note = StaffNote.find(params[:id])
    end
  end
end
