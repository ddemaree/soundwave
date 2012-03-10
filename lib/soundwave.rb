require 'hike'
require 'mustache'
require 'multi_json'

module Soundwave
  class Mustache < ::Mustache
    attr_reader :page

    def initialize(page=nil)
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

  class Site
    attr_accessor :source, :destination

    def initialize(source="./", destination="./_site")
      @source = Pathname(source).expand_path
    end

    def generate(destination)
      destination = Pathname(destination)
      Dir[source.join("**","*.mustache")].each do |path|
        next if File.basename(path).to_s =~ /^_/
        page = Page.new(self, path)
        page.write(destination.join(page.output_path))
      end
    end

    def data_trail
      @_data_path ||= Hike::Trail.new(source.join("_data")).tap do |t|
        t.append_path "."
        t.append_extension ".json"
        t.append_extension ".yml", ".yaml"
      end
    end
  end

  class Page
    attr_reader :site, :path

    def initialize(site, path)
      @site = site
      @path = Pathname(path).expand_path
    end

    def relative_path
      @path.relative_path_from(site.source).to_s
    end

    def output_path
      relative_path.sub('.mustache','.html')
    end

    def base_path
      relative_path.sub(".mustache",'')
    end

    def render
      Soundwave::Mustache.new(self).render(@path.read, self.read_data)
    end

    def write(destination)
      destination = Pathname(destination)
      puts "#{relative_path} => #{destination.relative_path_from(site.source)}"
      File.open(destination, "w") { |f| f.write(self.render) }
    end

    def read_data
      if data_file = site.data_trail.find(base_path)
        case File.extname(data_file)
        when ".yml"
          data = YAML.load(File.read(data_file))
        when ".json"
          data = MultiJson.decode(File.read(data_file))
        else
          data = {}
        end
      else
        data = {}
      end
    end
  end
end