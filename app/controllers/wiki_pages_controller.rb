# frozen_string_literal: true

class WikiPagesController < ApplicationController
  respond_to :html, :json, :js

  def index
    authorize(WikiPage)
    if params[:title].present?
      @wiki_page = WikiPage.titled(params[:title])
      if @wiki_page.nil?
        return redirect_to(show_or_new_wiki_pages_path(title: params[:id])) if request.format.html?
        raise(ActiveRecord::RecordNotFound)
      end
      redirect_to(wiki_page_path(@wiki_page))
    end
    @wiki_pages = WikiPage.search(search_params(WikiPage)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@wiki_pages) do |format|
      format.html do
        if params[:page].nil? || params[:page].to_i == 1
          if @wiki_pages.length == 1
            redirect_to(wiki_page_path(@wiki_pages.first))
          elsif @wiki_pages.empty? && params[:search][:title].present? && params[:search][:title] !~ /\*/
            redirect_to(wiki_pages_path(search: { title: "*#{params[:search][:title]}*" }))
          end
        end
      end
      format.json do
        render(json: @wiki_pages.to_json)
        expires_in(params[:expiry].to_i.days) if params[:expiry]
      end
    end
  end

  def show
    if params[:id] =~ /\A\d+\z/
      @wiki_page = authorize(WikiPage.find(params[:id]))
    else
      @wiki_page = WikiPage.titled(params[:id])
    end
    authorize(@wiki_page, policy_class: WikiPagePolicy)
    if @wiki_page.present?
      unless @wiki_page.parent.nil?
        @wiki_redirect = WikiPage.titled(@wiki_page.parent)
      end
      respond_with(@wiki_page)
    elsif request.format.html?
      redirect_to(show_or_new_wiki_pages_path(title: params[:id]))
    else
      raise(ActiveRecord::RecordNotFound)
    end
  end

  def new
    @wiki_page = authorize(WikiPage.new(permitted_attributes(WikiPage)))
    respond_with(@wiki_page)
  end

  def edit
    if params[:id] =~ /\A\d+\z/
      @wiki_page = WikiPage.find(params[:id])
    else
      @wiki_page = WikiPage.titled(params[:id])
      if @wiki_page.nil? && request.format.html?
        redirect_to(show_or_new_wiki_pages_path(title: params[:id]))
        return
      end
    end
    authorize(@wiki_page)
    ensure_can_edit(@wiki_page, CurrentUser.user)
    respond_with(@wiki_page)
  end

  def search
    authorize(WikiPage)
  end

  def create
    @wiki_page = authorize(WikiPage.new(permitted_attributes(WikiPage)))
    @wiki_page.save
    respond_with(@wiki_page)
  end

  def update
    @wiki_page = authorize(WikiPage.find(params[:id]))
    ensure_can_edit(@wiki_page, CurrentUser.user)
    @wiki_page.update(permitted_attributes(@wiki_page))
    respond_with(@wiki_page)
  end

  def destroy
    @wiki_page = authorize(WikiPage.find(params[:id]))
    @wiki_page.destroy
    notice(@wiki_page.valid? ? "Page destroyed" : @wiki_page.errors.full_messages.join("; "))
    respond_with(@wiki_page)
  end

  def revert
    @wiki_page = authorize(WikiPage.find(params[:id]))
    ensure_can_edit(@wiki_page, CurrentUser.user)
    @version = @wiki_page.versions.find(params[:version_id])
    @wiki_page.revert_to!(@version)
    notice("Page was reverted")
    respond_with(@wiki_page)
  end

  def show_or_new
    @wiki_page = authorize(WikiPage.titled(params[:title]), policy_class: WikiPagePolicy)
    if @wiki_page
      redirect_to(wiki_page_path(@wiki_page))
    else
      @wiki_page = WikiPage.new(title: params[:title])
      respond_with(@wiki_page)
    end
  end

  private

  def ensure_can_edit(page, user)
    return if user.is_janitor?
    raise(User::PrivilegeError, "Wiki page is locked.") if page.is_locked?
  end
end
