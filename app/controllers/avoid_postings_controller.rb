class AvoidPostingsController < ApplicationController
  respond_to :html, :json
  before_action :can_edit_avoid_posting_entries_only, except: %i[index show]
  before_action :load_avoid_posting, except: %i[index new create]

  def index
    @avoid_postings = authorize(AvoidPosting).search(search_params(AvoidPosting)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@avoid_postings)
  end

  def show
    authorize(@avoid_posting)
    respond_with(@avoid_posting)
  end

  def new
    @avoid_posting = authorize(AvoidPosting.new(permitted_attributes(AvoidPosting)))
    respond_with(@artist)
  end

  def edit
    authorize(@avoid_posting)
  end

  def create
    @avoid_posting = authorize(AvoidPosting.new(permitted_attributes(AvoidPosting)))
    @avoid_posting.save
    respond_with(@avoid_posting)
  end

  def update
    authorize(@avoid_posting).update(permitted_attributes(AvoidPosting))
    notice(@avoid_posting.valid? ? "Avoid posting updated" : @avoid_posting.errors.full_messages.join("; "))
    respond_with(@avoid_posting)
  end

  def destroy
    authorize(@avoid_posting).destroy
    notice("Avoid posting destroyed")
    respond_with(@avoid_posting)
  end

  def deactivate
    authorize(@avoid_posting).update(is_active: false)
    notice("Avoid posting deactivated")
    respond_with(@avoid_posting)
  end

  def reactivate
    authorize(@avoid_posting).update(is_active: true)
    notice("Avoid posting reactivated")
    respond_with(@avoid_posting)
  end

  private

  def load_avoid_posting
    id = params[:id]
    if id =~ /\A\d+\z/
      @avoid_posting = AvoidPosting.find(id)
    else
      @avoid_posting = AvoidPosting.find_by!(artist_name: id)
    end
  end
end
