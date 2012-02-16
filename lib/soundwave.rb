require "soundwave/version"
require "active_support/configurable"
require "digest/md5"

module Soundwave
  include ActiveSupport::Configurable

  self.configure do |config|
    config.exclude = ["bin", "Gemfile", "Gemfile.lock"]
    config.static_extensions = %w(.jpg .jpeg .png .gif)
  end

  config_accessor :static_extensions
end

# Load all submodules
Dir[File.expand_path("../soundwave/*.rb", __FILE__)].each { |f| require f }