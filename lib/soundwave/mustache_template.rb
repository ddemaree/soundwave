require 'mustache'
require 'pathname'

module Soundwave
  # Custom wrapper for Mustache, to enforce Soundwave conventions w/r/t
  # template and partial naming and provide a Tilt-like interface.
  class MustacheTemplate < ::Mustache

    # Public: Initializes a new MustacheTemplate
    #
    # pathname - Pathname for the template file
    #
    # Returns a MustacheTemplate object.
    def initialize(pathname)
      @pathname = Pathname(pathname)
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
end