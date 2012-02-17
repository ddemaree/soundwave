require 'mustache'

module Soundwave
  class RenderedPage < Document

    attr_accessor :data
    attr_reader :output

    def initialize(env, logical_path, pathname)
      super
      @data = {}
      read_data # is this necessary?
    end
    
    def output_path
      @env.output_dir.join(logical_path)
    end

    def mustache
      MustacheTemplate.new(@pathname)
    end

    def render
      read_data
      result = pathname.read
      processors.each do |processor|
        template = processor.new(pathname.to_s) { result }
        result   = template.render(@data)
      end

      @output ||= result
      result
    end
    alias_method :to_s, :render

    def write
      if changed?
        FileUtils.mkdir_p(output_path.dirname)
        File.open(output_path, "w") { |f| f.write(self.render()) }
      end
    end

  protected

    def processors
      file_attributes.engines
    end

    def read_data
      # Get site data
      @data = @env.site_data || {}

      basepath = file_attributes.logical_path.sub(/\..+/, '')
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