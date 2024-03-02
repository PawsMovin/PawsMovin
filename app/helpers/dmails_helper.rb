# frozen_string_literal: true

module DmailsHelper
  def all_dmails_path(params = {})
    dmails_path(folder: "all", **params)
  end

  def sent_dmails_path(params = {})
    dmails_path(folder: "sent", **params)
  end

  def received_dmails_path(params = {})
    dmails_path(folder: "received", **params)
  end
end
