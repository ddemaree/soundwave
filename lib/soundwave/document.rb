module Soundwave
  class Document

    attr_reader :mtime, :pathname, :logical_path

    def initialize(env, logical_path, absolute_path=nil)
      @env = env
      @logical_path = logical_path
      @pathname = Pathname(absolute_path || env.root_dir.join(logical_path))
      refresh
    end

    def output_path
      @env.output_dir.join(@logical_path)
    end

    def changed?
      @mtime != @pathname.stat.mtime
      true
    end

    def refresh
      @mtime = @pathname.stat.mtime
    end

    def file_attributes
      @env.attributes_for(self.pathname)
    end

    def write
      # Stub: override this in a subclass
    end
  end
end