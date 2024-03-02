# frozen_string_literal: true

class DmailsController < ApplicationController
  respond_to :html
  respond_to :json, except: %i[new create]
  before_action :member_only

  def new
    if params[:respond_to_id]
      parent = Dmail.find(params[:respond_to_id])
      check_privilege(parent)
      @dmail = parent.build_response(forward: params[:forward])
    else
      @dmail = Dmail.new(create_params)
    end

    respond_with(@dmail)
  end

  def index
    @query = Dmail.active.visible.for_folder(params[:folder]).search(search_params)
    @dmails = @query.paginate(params[:page], limit: params[:limit])
    respond_with(@dmails)
  end

  def show
    if params[:key].present?
      @dmail = Dmail.find_by!(id: params[:id], key: params[:key])
    else
      @dmail = Dmail.find(params[:id])
    end
    check_privilege(@dmail, :show)
    respond_with(@dmail) do |format|
      format.html { @dmail.mark_as_read! if CurrentUser.user == @dmail.owner }
    end
  end

  def create
    @dmail = Dmail.create_split(create_params)
    respond_with(@dmail)
  end

  def destroy
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_read!
    @dmail.update_column(:is_deleted, true)
    respond_to do |format|
      format.html { redirect_to(dmails_path, notice: "Message deleted") }
      format.json
    end
  end

  def mark_as_read
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_read!
  end

  def mark_as_unread
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_unread!
    respond_to do |format|
      format.html { redirect_to(dmails_path, notice: "Message marked as unread") }
      format.json
    end
  end

  def mark_all_as_read
    Dmail.visible.unread.each do |x|
      x.update_column(:is_read, true)
    end
    CurrentUser.user.update(unread_dmail_count: 0)
    respond_to do |format|
      format.html { redirect_to(dmails_path, notice: "All messages marked as read") }
      format.json
    end
  end

  private

  def check_privilege(dmail, action = nil)
    raise(User::PrivilegeError) unless dmail.visible_to?(CurrentUser.user, params[:key])
    raise(User::PrivilegeError) if CurrentUser.user != dmail.owner && action != :show
  end

  def search_params
    permit_search_params(%i[title_matches message_matches to_name to_id from_name from_id is_read is_deleted read owner_id owner_name])
  end

  def create_params
    params.fetch(:dmail, {}).permit(%i[title body to_name to_id])
  end
end
