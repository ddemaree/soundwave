require 'active_support/callbacks'

module Soundwave
  class Environment
    include ActiveSupport::Callbacks
    define_callbacks :read
    define_callbacks :generate

    attr_accessor :root_dir

    def initialize(root="./")
      @root_dir = Pathname(root)
    end

    def site_data
      # TODO: Implement something for getting global/site-level data from _data/_site.(yml|json)
      {}
    end

    def output_dir
      @output_dir ||= self.root_dir.join("_site")
    end

    def data_dir
      @data_dir ||= self.root_dir.join("_data")
    end

    def exclude
      @exclude ||= Soundwave.config.exclude
    end

    def pages
      @pages ||= {}
    end

    def static_extensions
      Soundwave.static_extensions
    end

    def read_directories(dir='')
      base = File.join(self.root_dir, dir)
      entries = Dir.chdir(base) { filter_entries(Dir['*']) }
      entries.each do |entry|
        absolute_path = File.join(base, entry)
        relative_path = File.join(dir, entry)
        logical_path = absolute_path.sub(self.root_dir.to_s, "")

        if File.directory?(absolute_path)
          # Recurse into directories
          read_directories(relative_path)
        else
          basename = File.basename(entry)
          extensions ||= basename.scan(/\.[^.]+/)
          engine = extensions[-1]

          # For right now, let's try supporting only Mustache
          if engine == ".mustache"
            logical_path = logical_path.sub('.mustache', '.html')
            add_page(logical_path, RenderedPage.new(self, logical_path, absolute_path))
          elsif static_extensions.include?(engine)
            add_page(logical_path, StaticFile.new(self, logical_path, absolute_path))
          else
            add_page(logical_path, StaticFile.new(self, logical_path, absolute_path))
          end

        end
      end
    end

    def add_page(logical_path, page)
      if pages[logical_path]
        raise "Page already exists: #{logical_path}"
      else
        pages[logical_path] = page
      end
    end

    def generate_site
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