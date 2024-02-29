# frozen_string_literal: true

id_name_constraint = { id: %r{[^/]+?}, format: /json|html/ }.freeze
Rails.application.routes.draw do
  require "sidekiq/web"
  require "sidekiq_unique_jobs/web"

  mount Sidekiq::Web => "/sidekiq", :constraints => AdminRouteConstraint.new

  namespace :admin do
    resources :users, only: %i[edit update edit_blacklist update_blacklist alt_list] do
      member do
        get :edit_blacklist
        post :update_blacklist
        get :request_password_reset
        post :password_reset
      end
      collection do
        get :alt_list
      end
    end
    resource :bulk_update_request_import, only: %i[new create]
    resource :dashboard, only: %i[show]
    resources :exceptions, only: %i[index show]
    resource :reowner, controller: "reowner", only: %i[new create]
    resource :stuck_dnp, controller: "stuck_dnp", only: %i[new create]
    resources :staff_notes, only: %i[index]
    resources :danger_zone, only: [:index] do
      collection do
        put :uploading_limits
      end
    end
    resources :audit_logs, only: %i[index]
  end
  resources :edit_histories, only: %i[index show] do
    get :diff, on: :collection
  end
  namespace :moderator do
    resource :dashboard, only: [:show]
    resources :ip_addrs, only: [:index] do
      collection do
        get :export
      end
    end
    resources :user_text_versions, only: %i[index show] do
      get :diff, on: :collection
    end
  end
  resources :api_keys
  resources :popular, only: %i[index] do
    collection do
      get :uploads
      get :views
      get :searches
      get "/searches/missed", to: "popular#missed_searches", as: "missed_searches"
    end
  end
  namespace :users do
    resource :count_fixes, only: %i[new create]
    resource :email_notification, only: %i[show destroy]
    resource :password_reset, only: %i[new create edit update]
    resource :login_reminder, only: %i[new create]
    resource :deletion, only: %i[show destroy]
    resource :email_change, only: %i[new create]
    resource :dmail_filter, only: %i[edit update]
  end

  resources :tickets, except: %i[destroy] do
    member do
      post :claim
      post :unclaim
    end
  end

  resources :takedowns do
    collection do
      post :count_matching_posts
    end
    member do
      post :add_by_ids
      post :add_by_tags
      post :remove_by_ids
    end
  end

  resources :artists, constraints: id_name_constraint do
    member do
      put :revert
    end
    collection do
      get :show_or_new
    end
  end
  resources :artist_urls, only: [:index]
  resources :artist_versions, only: [:index] do
    collection do
      get :search
    end
  end
  resources :bans
  resources :bulk_update_requests do
    member do
      post :approve
    end
  end
  resources :comments do
    resource :votes, controller: "comment_votes", only: %i[create destroy]
    collection do
      get :search
    end
    member do
      post :hide
      post :unhide
      post :warning
    end
  end
  resources :comment_votes, only: %i[index delete lock] do
    collection do
      post :lock
      post :delete
    end
  end
  resources :dmails, only: %i[new create index show destroy] do
    member do
      put :mark_as_read
      put :mark_as_unread
    end
    collection do
      put :mark_all_as_read
    end
  end
  resource :dtext_preview, only: [:create]
  resources :favorites, only: %i[index create destroy]
  resources :forum_posts do
    resource :votes, controller: "forum_post_votes", only: %i[create destroy]
    member do
      post :hide
      post :unhide
      post :warning
    end
    collection do
      get :search
    end
  end
  resources :forum_post_votes, only: %i[index destroy] do
    post :delete, on: :collection
  end
  resources :forum_topics do
    member do
      post :hide
      post :unhide
      post :subscribe
      post :unsubscribe
    end
    collection do
      post :mark_all_as_read
    end
  end
  resources :forum_categories, only: %i[index show new create edit update destroy] do
    post :reorder, on: :collection
  end
  resources :help_pages, controller: "help", path: "help"
  resources :ip_bans, only: %i[index new create destroy]
  resources :upload_whitelists, except: %i[show] do
    collection do
      get :is_allowed
    end
  end
  resources :email_blacklists, only: %i[new create destroy index]
  resource :iqdb_queries, only: [:show] do
    collection do
      post :show
    end
  end
  resources :mod_actions, only: %i[index show]
  resources :news_updates, except: %i[show]
  resources :notes do
    collection do
      get :search
    end
    member do
      put :revert
    end
  end
  resources :note_versions, only: [:index]
  resource :note_previews, only: [:show]
  resources :pools do
    member do
      put :revert
    end
    collection do
      get :gallery
    end
    resource :order, only: [:edit], controller: "pool_orders"
  end
  resource :pool_element, only: %i[create destroy]
  resources :pool_versions, only: [:index] do
    member do
      get :diff
    end
  end
  resources :post_replacements, only: %i[index new create destroy] do
    member do
      put :approve
      put :reject
      post :promote
      put :toggle_penalize
    end
  end
  resources :deleted_posts, only: [:index]
  resource :post_recommendations, only: %i[show]
  resources :posts, only: %i[index show update delete destroy] do
    resources :replacements, only: %i[index new create], controller: "post_replacements"
    resource :recommended, only: %i[show], controller: "post_recommendations"
    resource :similar, only: %i[show], controller: "iqdb_queries"
    resource :votes, controller: "post_votes", only: %i[create destroy]
    resource :flag, controller: "post_flags", only: [:destroy]
    resources :favorites, controller: "post_favorites", only: [:index]
    collection do
      get :random
      get :uploaders
    end
    member do
      get :update_iqdb
      put :revert
      put :copy_notes
      get :show_seq
      put :mark_as_translated
      get :comments, to: "comments#for_post"

      post :expunge
      get :delete
      post :undelete
      get :confirm_move_favorites
      post :move_favorites
      post :regenerate_thumbnails
      post :regenerate_videos
    end
  end
  resources :post_votes, only: %i[index delete lock] do
    collection do
      post :lock
      post :delete
    end
  end
  resources :post_events, only: :index
  resources :post_flags, except: %i[edit update]
  resources :post_approvals, only: %i[index create destroy]
  resources :post_disapprovals, only: %i[create index]
  resources :post_versions, only: [:index] do
    member do
      put :undo
    end
  end
  resource :related_tag, only: %i[show]
  match "related_tag/bulk", to: "related_tags#bulk", via: %i[get post]
  resource :session, only: %i[new create destroy confirm_password] do
    get :confirm_password, on: :collection
  end
  resources :stats, only: [:index]
  resources :tags, constraints: id_name_constraint, only: %i[index show edit update] do
    resource :correction, only: %i[new create show], controller: "tag_corrections"
    collection do
      post :preview
    end
  end
  resources :tag_type_versions, only: %i[index]
  resources :tag_aliases do
    post :approve, on: :member
  end
  resources :tag_implications do
    post :approve, on: :member
  end
  resources :uploads, only: %i[index show new create]
  resources :users do
    resource :password, only: [:edit], controller: "users/passwords"
    resources :api_keys, controller: "api_keys"
    resources :staff_notes, only: %i[index new create destroy undelete update], controller: "admin/staff_notes" do
      put :undelete
    end
    resources :text_versions, only: %i[index], to: "moderator/user_text_versions#for_user"
    resources :blocks, only: %i[index new create edit update destroy], controller: "users/blocks"

    collection do
      get :home
      get :search
      get :upload_limit
      get :custom_style
    end
  end
  resources :user_feedbacks do
    collection do
      get :search
    end
  end
  resources :user_name_change_requests, only: %i[index show new create]
  resource :user_revert, only: %i[new create]
  resources :wiki_pages, constraints: id_name_constraint do
    member do
      put :revert
    end
    collection do
      get :search
      get :show_or_new
    end
  end
  resources :wiki_page_versions, only: %i[index show diff] do
    collection do
      get :diff
    end
  end
  resources :post_sets do
    collection do
      get :for_select
    end
    member do
      get :maintainers
      get :post_list
      post :update_posts
      post :add_posts
      post :remove_posts
    end
  end
  resources :post_deletion_reasons, only: %i[index new create edit update destroy] do
    post :reorder, on: :collection
  end
  resources :post_set_maintainers, only: %i[index create] do
    member do
      get :approve
      get :block
      get :deny
    end
  end
  resource :email, only: %i[] do
    collection do
      get :activate_user
      get :resend_confirmation
    end
  end
  resources :mascots, only: %i[index new create edit update destroy]

  options "*all", to: "application#enable_cors"

  # aliases
  resources :wpages, controller: "wiki_pages"
  resources :ftopics, controller: "forum_topics"
  resources :fposts, controller: "forum_posts"

  # legacy aliases
  get "/artist" => redirect { |_params, req| "/artists?page=#{req.params[:page]}&search[name]=#{CGI.escape(req.params[:name].to_s)}" }
  get "/artist/index" => redirect { |_params, req| "/artists?page=#{req.params[:page]}" }
  get "/artist/show/:id" => redirect("/artists/%{id}")
  get "/artist/show" => redirect { |_params, req| "/artists?name=#{CGI.escape(req.params[:name].to_s)}" }
  get "/artist/history/:id" => redirect("/artist_versions?search[artist_id]=%{id}")
  get "/artist/recent_changes" => redirect("/artist_versions")

  get "/comment" => redirect { |_params, req| "/comments?page=#{req.params[:page]}" }
  get "/comment/index" => redirect { |_params, req| "/comments?page=#{req.params[:page]}" }
  get "/comment/show/:id" => redirect("/comments/%{id}")
  get "/comment/new" => redirect("/comments")
  get("/comment/search" => redirect do |_params, req|
    if req.params[:query] =~ /^user:(.+)/i
      "/comments?group_by=comment&search[creator_name]=#{CGI.escape($1)}"
    else
      "/comments/search"
    end
  end)

  get "/favorite" => redirect { |_params, req| "/favorites?page=#{req.params[:page]}" }
  get "/favorite/index" => redirect { |_params, req| "/favorites?page=#{req.params[:page]}" }

  get "/forum" => redirect { |_params, req| "/forum_topics?page=#{req.params[:page]}" }
  get "/forum/index" => redirect { |_params, req| "/forum_topics?page=#{req.params[:page]}" }
  get "/forum/show/:id" => redirect { |_params, req| "/forum_posts/#{req.params[:id]}?page=#{req.params[:page]}" }
  get "/forum/search" => redirect("/forum_posts/search")

  get "/help/show/:title" => redirect("/help/%{title}")

  get "/note" => redirect { |_params, req| "/notes?page=#{req.params[:page]}" }
  get "/note/index" => redirect { |_params, req| "/notes?page=#{req.params[:page]}" }
  get "/note/history" => redirect { |_params, req| "/note_versions?search[updater_id]=#{req.params[:user_id]}" }

  get "/pool" => redirect { |_params, req| "/pools?page=#{req.params[:page]}" }
  get "/pool/index" => redirect { |_params, req| "/pools?page=#{req.params[:page]}" }
  get "/pool/show/:id" => redirect("/pools/%{id}")
  get "/pool/history/:id" => redirect("/pool_versions?search[pool_id]=%{id}")
  get "/pool/recent_changes" => redirect("/pool_versions")

  get "/post/index/:page/:tags" => redirect { |params, _req| "/posts?tags=#{CGI.escape(params[:tags].to_s)}&page=#{params[:page].to_i}" }
  get "/post/index/:page" => redirect { |params, _req| "/posts?tags=&page=#{params[:page].to_i}" }
  get "/post/index" => redirect { |_params, req| "/posts?tags=#{CGI.escape(req.params[:tags].to_s)}&page=#{req.params[:page]}" }
  get "/post" => redirect { |_params, req| "/posts?tags=#{CGI.escape(req.params[:tags].to_s)}&page=#{req.params[:page]}" }
  get "/post/upload" => redirect("/uploads/new")
  get "/post/atom" => redirect { |_params, req| "/posts.atom?tags=#{CGI.escape(req.params[:tags].to_s)}" }
  get "/post/atom.feed" => redirect { |_params, req| "/posts.atom?tags=#{CGI.escape(req.params[:tags].to_s)}" }
  get "/post/popular_by_day" => redirect("/popular")
  get "/post/popular_by_week" => redirect("/popular")
  get "/post/popular_by_month" => redirect("/popular")
  # This redirect preserves all query parameters and the request format
  get "/explore/posts/popular(*all)" => redirect(path: "/popular%{all}"), :defaults => { all: "" }
  get "/post/show/:id/:tag_title" => redirect("/posts/%{id}")
  get "/post/show/:id" => redirect("/posts/%{id}")
  get "/post/show" => redirect { |_params, req| "/posts?md5=#{req.params[:md5]}" }
  get "/post/view/:id/:tag_title" => redirect("/posts/%{id}")
  get "/post/view/:id" => redirect("/posts/%{id}")
  get "/post/flag/:id" => redirect("/posts/%{id}")

  get("/post_tag_history" => redirect do |_params, req|
    page = req.params[:before_id].present? ? "b#{req.params[:before_id]}" : req.params[:page]
    "/post_versions?page=#{page}&search[updater_id]=#{req.params[:user_id]}"
  end)
  get "/post_tag_history/index" => redirect { |_params, req| "/post_versions?page=#{req.params[:page]}&search[post_id]=#{req.params[:post_id]}" }

  get "/tag" => redirect { |_params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}&search[category]=#{req.params[:type]}" }
  get "/tag/index" => redirect { |_params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}" }

  get "/tag_implication" => redirect { |_params, req| "/tag_implications?search[name_matches]=#{CGI.escape(req.params[:query].to_s)}" }
  get "/tag_alias" => redirect { |_params, req| "/tag_aliases?search[antecedent_name]=#{CGI.escape(req.params[:query].to_s)}&search[consequent_name]=#{CGI.escape(req.params[:aliased_to].to_s)}" }

  get "/takedown/show/:id" => redirect("/takedowns/%{id}")

  get "/user" => redirect { |_params, req| "/users?page=#{req.params[:page]}" }
  get "/user/index" => redirect { |_params, req| "/users?page=#{req.params[:page]}" }
  get "/user/show/:id" => redirect("/users/%{id}")
  get "/user/login" => redirect("/session/new")
  get "/user_record" => redirect { |_params, req| "/user_feedbacks?search[user_id]=#{req.params[:user_id]}" }

  get "/wiki" => redirect { |_params, req| "/wiki_pages?page=#{req.params[:page]}" }
  get "/wiki/index" => redirect { |_params, req| "/wiki_pages?page=#{req.params[:page]}" }
  get "/wiki/rename" => redirect("/wiki_pages")
  get "/wiki/show/:title" => redirect("/wiki_pages/%{title}")
  get "/wiki/show" => redirect { |_params, req| "/wiki_pages?title=#{CGI.escape(req.params[:title].to_s)}" }
  get "/wiki/recent_changes" => redirect { |_params, req| "/wiki_page_versions?search[updater_id]=#{req.params[:user_id]}" }
  get "/wiki/history/:title" => redirect("/wiki_page_versions?title=%{title}")

  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/privacy" => "static#privacy", :as => "privacy_policy"
  get "/static/takedown" => "static#takedown", :as => "takedown_static"
  get "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  get "/static/contact" => "static#contact", :as => "contact"
  get "/static/discord" => "static#discord", :as => "discord_get"
  post "/static/discord" => "static#discord", :as => "discord_post"
  get "/static/toggle_mobile_mode" => "static#disable_mobile_mode", :as => "disable_mobile_mode"
  get "/static/theme" => "static#theme", :as => "theme"
  get "/meta_searches/tags" => "meta_searches#tags", :as => "meta_searches_tags"
  get "/route", to: "application#dump_route"

  root to: "static#home"

  get "*other", to: "static#not_found"
end
