module Soundwave
  class Document
    def initialize(env, relative_path, absolute_path)
      @env = env
      @relative_path = relative_path
      @pathname = Pathname(absolute_path)
      @mtime = @pathname.stat.mtime
    end

    def output_path
      @env.output_dir.join(@relative_path)
    end
  end
end