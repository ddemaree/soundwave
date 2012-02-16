module Soundwave
  class StaticFile < Soundwave::Document
    def write
      if changed?
        FileUtils.mkdir_p(output_path.dirname)
        FileUtils.cp(@pathname, output_path)
      end
    end

    def changed?
      file_d = Digest::MD5.file(output_path)
      content_d = Digest::MD5.file(@pathname)
      file_d != content_d
    end
  end
end