require 'rake'
require 'rake/tasklib'
require 'soundwave'

module Soundwave
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name, :site, :destination

    def initialize(name=:pages, source="./", destination="./_site")
      @name = name
      @site = Site.new(source)
      @destination = Pathname(destination).expand_path
      define
    end

    def define
      desc "Build pages in #{@site.source}"
      task(name) do
        @site.generate(@destination)
      end
    end
  end
end