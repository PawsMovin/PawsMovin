# frozen_string_literal: true

class Presenter
  def self.h(string)
    CGI.escapeHTML(string.to_s)
  end

  def self.u(string)
    URI.escape(string)
  end

  def h(string)
    CGI.escapeHTML(string)
  end

  def u(string)
    CGI.escape(string)
  end
end
