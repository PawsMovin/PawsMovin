# frozen_string_literal: true

class PostsDecorator < ApplicationDecorator
  def self.collection_decorator_class
    PaginatedDecorator
  end

  alias post object

  delegate_all

  def preview_class(options)
    klass = ["post-preview"]
    klass << "post-status-pending" if post.is_pending?
    klass << "post-status-flagged" if post.is_flagged?
    klass << "post-status-deleted" if post.is_deleted?
    klass << "post-status-has-parent" if post.parent_id
    klass << "post-status-has-children" if post.has_visible_children?
    klass << "post-rating-safe" if post.rating == "s"
    klass << "post-rating-questionable" if post.rating == "q"
    klass << "post-rating-explicit" if post.rating == "e"
    klass << "post-no-blacklist" if options[:no_blacklist]
    klass
  end

  def data_attributes
    attributes = {
      "data-id":           post.id,
      "data-has-sound":    post.has_tag?("sound"),
      "data-tags":         post.tag_string,
      "data-rating":       post.rating,
      "data-flags":        post.status_flags,
      "data-uploader-id":  post.uploader_id,
      "data-uploader":     post.uploader_name,
      "data-file-ext":     post.file_ext,
      "data-file-size":    post.file_size,
      "data-score":        post.score,
      "data-score-up":     post.up_score,
      "data-score-down":   post.down_score,
      "data-fav-count":    post.fav_count,
      "data-is-favorited": post.favorited_by?(CurrentUser.user.id),
      "data-own-vote":     post.own_vote,
      "data-created-at":   post.created_at.iso8601,
      "data-created-ago":  "#{Class.new.extend(ActionView::Helpers::DateHelper).time_ago_in_words(post.created_at)} ago",
      "data-width":        post.image_width,
      "data-height":       post.image_height,
    }

    if post.visible?
      attributes["data-md5"] = post.md5
      attributes["data-file-url"] = post.file_url
      attributes["data-large-file-url"] = post.large_file_url
      attributes["data-preview-file-url"] = post.preview_file_url
    end

    attributes
  end

  def cropped_url(options)
    cropped_url = if PawsMovin.config.enable_image_cropping? && options[:show_cropped] && object.has_cropped? && !CurrentUser.user.disable_cropped_thumbnails?
                    object.crop_file_url
                  else
                    object.preview_file_url
                  end

    cropped_url = PawsMovin.config.deleted_preview_url if object.deleteblocked?
    cropped_url
  end

  def score_class(score)
    return "score-neutral" if score == 0
    score > 0 ? "score-positive" : "score-negative"
  end

  def preview_html(template, options = {})
    return "" if post.nil?

    if !options[:show_deleted] && post.is_deleted? && options[:tags] !~ /(?:status:(?:all|any|deleted))|(?:deletedby:)|(?:delreason:)/i
      return ""
    end

    if post.loginblocked? || post.safeblocked?
      return ""
    end

    article_attrs = {
      id:    "post_#{post.id}",
      class: preview_class(options).join(" "),
    }.merge(data_attributes)

    link_target = options[:link_target] || post

    link_params = {}
    if options[:tags].present?
      link_params["q"] = options[:tags]
    end
    if options[:pool_id]
      link_params["pool_id"] = options[:pool_id]
    end
    if options[:post_set_id]
      link_params["post_set_id"] = options[:post_set_id]
    end

    tooltip = "Rating: #{post.rating}\nID: #{post.id}\nDate: #{post.created_at}\nStatus: #{post.status}\nScore: #{post.score}"
    tooltip += "\nUploader: #{post.uploader_name}" if CurrentUser.user.is_janitor? || CurrentUser.user.show_post_uploader?
    if CurrentUser.user.is_janitor? && (post.is_flagged? || post.is_deleted?)
      flag = post.flags.order(id: :desc).first
      tooltip += "\nFlag Reason: #{flag&.reason}" if post.is_flagged?
      tooltip += "\nDel Reason: #{flag&.reason}" if post.is_deleted?
    end
    tooltip += "\n\n#{post.tag_string}"

    cropped_url = if PawsMovin.config.enable_image_cropping? && options[:show_cropped] && post.has_cropped? && !CurrentUser.user.disable_cropped_thumbnails?
                    post.crop_file_url
                  else
                    post.preview_file_url
                  end

    cropped_url = PawsMovin.config.deleted_preview_url if post.deleteblocked?
    preview_url = if post.deleteblocked?
                    PawsMovin.config.deleted_preview_url
                  else
                    post.preview_file_url
                  end

    alt_text = post.tag_string

    has_cropped = post.has_cropped?

    pool = options[:pool]

    similarity = options[:similarity]&.round

    size = options[:size] ? post.file_size : nil

    img_contents = template.link_to(template.polymorphic_path(link_target, link_params)) do
      template.tag.picture do
        template.concat(template.tag.source(media: "(max-width: 800px)", srcset: cropped_url))
        template.concat(template.tag.source(media: "(min-width: 800px)", srcset: preview_url))
        template.concat(template.tag.img(class: "has-cropped-#{has_cropped}", src: preview_url, title: tooltip, alt: alt_text))
      end
    end
    desc_contents = if options[:stats] || pool || similarity || size
                      template.tag.div(class: "desc") do
                        template.post_stats_section(post) if options[:stats]
                      end
                    else
                      "".html_safe
                    end

    ribbons = ribbons(template)
    # ribbons = t.render("posts/partials/index/ribbons", post: post).html_safe
    vote_buttons = vote_buttons(template)
    # vote_buttons = t.render("posts/partials/index/vote_buttons", post: post, vote: vote).html_safe
    template.tag.article(**article_attrs) do
      img_contents + desc_contents + ribbons + vote_buttons
    end
  end

  def ribbons(template)
    template.tag.div(class: "ribbons") do # rubocop:disable Metrics/BlockLength
      [if post.parent_id.present?
         if post.has_visible_children?
           template.tag.div(class: "ribbon left has-parent has-children", title: "Has Parent\nHas Children") do
             template.tag.span
           end
         else
           template.tag.div(class: "ribbon left has-parent", title: "Has Parent") do
             template.tag.span
           end
         end
       elsif post.has_visible_children?
         template.tag.div(class: "ribbon left has-children", title: "Has Children") do
           template.tag.span
         end
       end,
       if post.is_flagged?
         if post.is_pending?
           template.tag.div(class: "ribbon right is-flagged is-pending", title: "Flagged\nPending") do
             template.tag.span
           end
         else
           template.tag.div(class: "ribbon right is-flagged", title: "Flagged") do
             template.tag.span
           end
         end
       elsif post.is_pending?
         template.tag.div(class: "ribbon right is-pending", title: "Pending") do
           template.tag.span
         end
       end,].join.html_safe
    end
  end

  def vote_buttons(template)
    template.tag.div(id: "vote-buttons") do
      template.tag.button("", class: "button vote-button vote score-neutral", disabled: post.is_vote_locked?, data: { action: "up" }) do
        template.tag.span(class: "post-vote-up-#{post.id} score-#{post.is_voted_up? ? 'positive' : 'neutral'}")
      end +
        template.tag.button("", class: "button vote-button vote score-neutral", disabled: post.is_vote_locked?, data: { action: "down" }) do
          template.tag.span(class: "post-vote-down-#{post.id} score-#{post.is_voted_down? ? 'negative' : 'neutral'}")
        end +
        template.tag.button("", class: "button vote-button fav score-neutral", data: { action: "fav", state: post.is_favorited? }) do
          template.tag.span(class: "post-favorite-#{post.id} score-neutral#{post.is_favorited? ? ' is-favorited' : ''}")
        end
    end
  end
end
