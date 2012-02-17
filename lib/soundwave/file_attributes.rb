require 'pathname'

module Soundwave
  class FileAttributes
    attr_reader :environment, :pathname

    def initialize(environment, pathname)
      @environment = environment
      @pathname = Pathname(pathname)
    end

    def logical_path
      if root_path = pathname.expand_path.to_s[environment.root_dir.to_s]
        path = pathname.to_s.sub("#{root_path}/", '')
        path = pathname.expand_path.relative_path_from(Pathname.new(root_path)).to_s
        path = engine_extensions.inject(path) { |p, ext| p.sub(ext, '') }
        path = "#{path}#{engine_format_extension}" unless format_extension
        path
      else
        raise "File outside paths"
      end
    end

    def extensions
      @extensions ||= @pathname.basename.to_s.scan(/\.[^.]+/)
    end

    def format_extension
      extensions.reverse.detect { |ext|
        # TODO: Environment may need a mime types registry
        !@environment.engines(ext)
      }
    end

    def engine_extensions
      exts = extensions

      if offset = extensions.index(format_extension)
        exts = extensions[offset+1..-1]
      end

      exts.select { |ext| @environment.engines(ext) }
    end

    def engines
      engine_extensions.map { |ext| @environment.engines(ext) }
    end

    private

      def engine_format_extension
        # TODO: Engines should provide a default extension, this should be engines.first.default_extension
        ".html"
      end
  end
end