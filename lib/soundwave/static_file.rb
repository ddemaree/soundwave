module Soundwave
  class StaticFile < Soundwave::Document
    def write
      if changed?
        FileUtils.mkdir_p(output_path.dirname.to_s)
        FileUtils.cp(@pathname, output_path)
      end
    end
  end
end