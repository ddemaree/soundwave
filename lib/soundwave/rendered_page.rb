require 'mustache'

module Soundwave
  class RenderedPage < Document

    # Custom wrapper for Mustache, to enforce Soundwave conventions w/r/t
    # template and partial naming.
    class Context < ::Mustache

      # Public: Initializes a new RenderedPage::Context.
      #
      # page     - The RenderedPage this belongs to
      # pathname - Pathname for the template file
      #
      # Returns a Context object.
      def initialize(page, pathname)
        @page = page
        @pathname = pathname
      end

      # Public: Reads the template file from disk and returns its
      # contents as a String.
      def template
        @pathname.read
      end

      # Public: Reads the partial template with the given name and
      # returns its contents.
      def partial(name)
        # TODO: Make this a teeny bit more robust?
        name = '_includes/' + name.to_s
        super
      end
    end

    def initialize(env, relative_path, absolute_path)
      super
      @data = {}
      read_data
    end
    
    def output_path
      @env.output_dir.join(@relative_path)
    end

    def mustache
      Context.new(self, @pathname)
    end

    def render(data={})
      read_data
      self.mustache.render(@data)
    end
    alias_method :to_s, :render

    def write
      if changed?
        FileUtils.mkdir_p(output_path.dirname)
        File.open(output_path, "w") { |f| f.write(self.render()) }
      end
    end

    def changed?
      file_d = Digest::MD5.file(output_path)
      content_d = Digest::MD5.hexdigest(self.render())
      file_d != content_d
    end

  protected

    def read_data
      # Get site data
      @data = @env.site_data || {}

      basepath = @pathname.to_s.sub(@env.root_dir.to_s, "").sub(/\..+/, '')
      data_file = @env.data_dir.join(basepath + ".yml")

      if File.exists?(data_file)
        page_data = YAML.load_file(data_file)
      else
        page_data = {}
      end

      @data.merge!(page_data)

      # TODO: YAML frontmatter?

      @data
    end
  end
end