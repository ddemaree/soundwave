require "soundwave"
require "soundwave/page"
require "rack"

module Soundwave
  class Server

    def initialize(site)
      @site = site
    end

    def call(env)
      if page = find_page(env["PATH_INFO"])
        respond_with 200, page.render, page.content_type
      else
        respond_with 404, "Not Found"
      end
    end

    def find_template(logical_path, format_extension=".mustache")
      template_trail.find(
        logical_path,
        logical_path.sub(".html", ".mustache"),
        logical_path + format_extension,
        File.join(logical_path, "index" + format_extension)
      )
    end

    def find_page(logical_path, format_extension=".mustache")
      if template = find_template(logical_path, format_extension)
        Page.new(@site, template)
      end
    end

    def respond_with(status, body, content_type = "text/html; charset=utf-8")
      headers = {
        "Content-Type"   => content_type,
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }
      [status, headers, [body]]
    end

  protected

    def template_trail
      @_template_trail ||= Hike::Trail.new(@site.source).tap do |t|
        t.extensions.replace(Soundwave::Page::ENGINES)
        t.append_path "."
      end
    end

  end
end 