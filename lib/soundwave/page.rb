#### Prerequisites

# We need to require the `soundwave` lib, for the Site class
require 'soundwave'

# Template engines: Mustache for basic HTML pages, Tilt for more complex views/assets
require 'mustache'
require 'tilt'

#### Soundwave::Mustache

# We need to subclass Mustache in order to implement our own partial-finding behavior.
module Soundwave
  class Mustache < ::Mustache
    attr_reader :page

    # `Soundwave::Mustache` takes a `Page`, for its template source and partial path
    def initialize(page)
      @page = page
    end

    def site
      @page.site
    end

    def template
      @page.path.read
    end

    def partial_path(name)
      name = name.to_s
      dirname = File.dirname(name)
      basename = File.basename(name)
      partialname = "_#{basename}"
      File.join(dirname, partialname)
    end

    def partial(name)
      @paths ||= [@page.path.dirname, site.source.join("includes"), Dir.pwd].map(&:to_s).uniq
      @trail ||= Hike::Trail.new(@page.site.source).tap do |t|
        t.append_extension ".mustache"
        @paths.each { |p| t.append_path(p) }
      end

      if path = (@trail.find(partial_path(name)) || @trail.find(name.to_s))
        File.read(path)
      end
    end
  end

  #### Soundwave::Page

  class Page
    attr_reader :site, :path
    attr_accessor :data

    DEFAULT_FORMATS = {
      ".mustache" => ".html"
    }

    ENGINES = [".mustache"] + Tilt.mappings.keys.map { |ext| ".#{ext}" }

    def initialize(site, path)
      @site = site
      @path = Pathname(path).expand_path
      @data = {}
    end

    def basename
      @basename ||= File.basename(path.to_s)
    end

    def extensions
      @extensions ||= basename.scan(/\.[^.]+/)
    end

    def format_extension
      if extensions.length == 1 && DEFAULT_FORMATS[extensions[0]]
        DEFAULT_FORMATS[extensions[0]]
      elsif engine_extension
        extensions[0]
      else
        extensions[-1]
      end
    end

    # By convention, files that are to be processed should be named in Rails/Sprockets-like format, e.g. `name.format.engine`.
    def engine_extension
      extensions.select { |e| ENGINES.include?(e) }[-1]
    end

    # This is used by `Soundwave::Server` to identify the appropriate content type for Rack serving.
    def content_type
      @content_type ||= begin
        type = Rack::Mime.mime_type(format_extension)
        type[/^text/] ? "#{type}; charset=utf-8" : type
      end
    end

    def relative_path
      @path.relative_path_from(site.source).to_s
    end

    def logical_path
      path = relative_path.dup

      if engine_extension
        path = path.sub(engine_extension, '')
        path = "#{path}#{format_extension}" unless path.include?(format_extension)
      end

      path
    end
    alias :output_path :logical_path

    def base_path
      relative_path.sub(".mustache",'')
    end

    def render
      if engine_extension
        if engine_extension == ".mustache"
          Soundwave::Mustache.new(self).render(@path.read, self.read_data)
        else
          template = Tilt.new(@path.to_s)
          template.render(nil, self.read_data)
        end
      else
        File.read(@path.to_s)
      end
    end

    def write(destination)
      destination = Pathname(destination)
      puts "#{relative_path} => #{destination.relative_path_from(site.source)}"
      FileUtils.mkdir_p(destination.dirname)
      File.open(destination, "w") { |f| f.write(self.render) }
    end

    def read_data
      if data_file = site.data_trail.find(base_path)
        case File.extname(data_file)
        when ".yml"
          YAML.load(File.read(data_file))
        when ".json"
          MultiJson.decode(File.read(data_file))
        else
          {}
        end
      else
        {}
      end
    rescue => e
      {}
    end
  end
end