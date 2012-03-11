# **Soundwave** is a tool for generating static web pages with structured data,
# with [Mustache][mo] or [Tilt][tilt] templates, and data files formatted as 
# YAML or JSON. I use it to rapidly prototype blog themes, and other kinds of
# highly structured websites.
#
# Information on installing and using Soundwave can be found in the README.
#
# Before I forget: Soundwave is &copy;2012— [David Demaree](http://demaree.me),
# released as open source software under the MIT license.
#
#### Prerequisites

# [Hike](http://github.com/sstephenson/hike) is used to set up and query load paths.
# We'll be using it to find partials, data files, and (in `Soundwave::Server`) templates.
require 'hike'

# [MultiJson](http://github.com/intridea/multi_json) is a universal Ruby wrapper around
# several popular JSON parsing and decoding libraries.
require 'multi_json'

#### Public Interface

module Soundwave
  VERSION = '0.4.0'

  # Most major stuff in Soundwave revolves around the `Site` class. Sites are
  # collections of templates and other files stored in a directory in the filesystem.

  class Site

    attr_accessor :source, :data_dir

    # `Soundwave::Site.new` takes an optional `source` path, defaults to the current directory.
    def initialize(source="./")
      @source = Pathname(source).expand_path
      # `data_dir` defaults to the `_data` directory under `source`.
      @data_dir = source.join("_data")
    end

    # The aptly named `generate` takes a `destination` path for the generated web pages.
    def generate(destination)
      destination = Pathname(destination)
      # TODO: Expand to handle all files, not just Mustache.
      #
      # First, we find all of the `.mustache` files in the project and iterate over that list.
      # Files whose basenames start with an underscore (_) are skipped.
      #
      # Next, we create a [Page](./soundwave/page.html) object for each file and write it to
      # the destination path.
      Dir[source.join("**","*.mustache")].each do |path|
        next if File.basename(path).to_s =~ /^_/

        page = Page.new(self, path)
        page.write(destination.join(page.output_path))
      end
    end

    private

    def data_trail
      @_data_path ||= Hike::Trail.new(data_dir).tap do |t|
        t.append_path "."
        t.extensions.replace([".json", ".yml", ".yaml"])
      end
    end
  end
end