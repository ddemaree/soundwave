require 'active_support/callbacks'
require 'tilt'

module Soundwave
  class Environment
    include ActiveSupport::Callbacks
    define_callbacks :read
    define_callbacks :generate

    attr_accessor :root_dir, :output_dir, :exclude, :data_dir

    def initialize(root="./")
      @root_dir     = Pathname(root).expand_path
      @exclude      = Soundwave.config.exclude
      @output_dir ||= @root_dir.join("_site")
      @data_dir   ||= @root_dir.join("_data")

      # TODO: Nicer interface around engines?
      @engines = {
        ".mustache" => Soundwave::MustacheTemplate,
        ".scss"     => Tilt::ScssTemplate,
        ".erb"      => Tilt::ERBTemplate
      }
    end

    def site_data
      # TODO: Implement something for getting global/site-level data from _data/_site.(yml|json)
      {}
    end

    def pages
      @pages ||= {}
    end

    def engines(ext)
      @engines[ext]
    end

    def register_engine(ext, engine)
      @engines[ext] = engine
    end

    def attributes_for(pathname)
      FileAttributes.new(self, pathname) 
    end

    def build_page(logical_path, pathname)
      attrs = attributes_for(pathname)

      if attrs.engines.any?
        RenderedPage.new(self, logical_path, pathname)
      else
        StaticFile.new(self, logical_path, pathname)
      end
    end

    def read_directories(dir='')
      base = File.join(self.root_dir, dir)
      entries = Dir.chdir(base) { filter_entries(Dir['*']) }
      entries.each do |entry|
        absolute_path = File.join(base, entry)
        relative_path = File.join(dir, entry)
        logical_path = absolute_path.sub(self.root_dir.to_s, "")

        if File.directory?(absolute_path)
          read_directories(relative_path)
        else
          pathname = Pathname(absolute_path).expand_path
          attrs = attributes_for(pathname)
          logical_path = attrs.logical_path
          pages[logical_path] = build_page(logical_path, pathname)
        end
      end
    end

    def generate
      run_callbacks(:read) do
        read_directories
      end
      run_callbacks(:generate) do
        @pages.each do |logical_path, page|
          puts "#{logical_path} => #{page.output_path}"
          page.write
        end
      end
    end

    # Deprecated: Alias to #generate for the two extant projects that use this code
    alias_method :generate_site, :generate

    # Exclude .dotfiles, _underscores, #hashes, ~tildes, paths in @exclude
    # and symlinks, EXCEPT for .htaccess
    def filter_entries(entries)
      entries = entries.reject do |e|
        unless ['.htaccess'].include?(e)
          ['.', '_', '#'].include?(e[0..0]) ||
          e[-1..-1] == '~' ||
          self.exclude.include?(e) ||
          File.symlink?(e)
        end
      end
    end
  end
end