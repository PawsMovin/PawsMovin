# frozen_string_literal: true

module Admin
  class StaffNotesController < ApplicationController
    before_action :can_view_staff_notes_only
    before_action :load_staff_note, only: %i[destroy update]
    before_action :check_delete_privilege, only: %i[destroy]
    before_action :check_edit_privilege, only: %i[update]
    respond_to :html

    def index
      @user = User.find_by(id: params[:user_id])
      @notes = StaffNote.search(search_params.merge({ user_id: params[:user_id] })).includes(:user, :creator).paginate(params[:page])
      respond_with(@notes)
    end

    def new
      @user = User.find(params[:user_id])
      @staff_note = StaffNote.new(staff_note_params)
      respond_with(@note)
    end

    def create
      @user = User.find(params[:user_id])
      @staff_note = StaffNote.create(staff_note_params.merge({ user_id: @user.id }))
      flash[:notice] = @staff_note.valid? ? "Staff Note added" : @staff_note.errors.full_messages.join("; ")
      respond_with(@staff_note) do |format|
        format.html do
          redirect_back fallback_location: admin_staff_notes_path
        end
      end
    end

    def update
      @staff_note.update(staff_note_params)
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    def destroy
      @staff_note.update(is_deleted: true)
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    def undelete
      @staff_note = StaffNote.find(params[:staff_note_id])
      raise User::PrivilegeError unless @staff_note.can_delete?(CurrentUser.user)

      @staff_note.update(is_deleted: false)
      redirect_back(fallback_location: admin_staff_notes_path)
    end

    private

    def staff_note_params
      params.fetch(:staff_note, {}).permit(%i[body])
    end

    def load_staff_note
      @staff_note = StaffNote.find(params[:id])
    end

    def check_delete_privilege
      raise User::PrivilegeError unless @staff_note.can_delete?(CurrentUser.user)
    end

    def check_edit_privilege
      raise User::PrivilegeError unless @staff_note.can_edit?(CurrentUser.user)
    end
  end
end
