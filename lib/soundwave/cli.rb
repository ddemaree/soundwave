module Soundwave
  module CLI
    extend self

    def run
      require 'optparse'

      help = <<HELP
Soundwave processes Mustache templates and YAML/JSON data into static web pages.

Usage: 
- soundwave [options]
  Processes all .mustache files in the current directory.

- soundwave [options] SOURCE [DESTINATION ...]
  Processes all .mustache files in SOURCE, and outputs them to DESTINATION.
  If DESTINATION is empty, defaults to SOURCE/_site.

- soundwave [options] FILENAME [DESTINATION ...]
  Renders the Mustache template at FILENAME and writes it to DESTINATION 
  if given, or to STDOUT.

Options:
HELP

      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = help

        opts.on("--version", "Display current version") do
          puts "Soundwave " + Soundwave::VERSION
          exit 0
        end

        opts.on("-i DIRECTORY", "--includes-dir=DIRECTORY", "Adds DIRECTORY to includes path") do |directory|
          options[:include_dirs] ||= []
          options[:include_dirs] << directory
        end

        opts.on("-d DIRECTORY", "--data-dir=DIRECTORY", "Adds DIRECTORY to data path") do |directory|
          options[:data_dirs] ||= []
          options[:data_dirs] << directory
        end
      end

      opts.parse!

      source = ARGV.shift || "./"

      if File.directory?(source)
        puts "Generating website in #{source}"
        site = Site.new(source)
        destination = ARGV.shift || site.source.join("_site")
        site.generate(destination)
      else
        site = Site.new("./")
        page = Page.new(site, source)
        if destination = ARGV.shift
          destination = site.source.join(destination)
          page.write(destination)
        else
          puts page.render
        end
      end
    end
  end
end