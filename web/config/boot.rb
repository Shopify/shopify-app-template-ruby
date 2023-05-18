# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
ENV["SHOPIFY_APP_URL"] = "https://#{ENV["SHOPIFY_APP_URL"]}" unless ENV["SHOPIFY_APP_URL"]&.match(%r{https?://})
ENV["HOST"] = "https://#{ENV["HOST"]}" unless ENV["HOST"]&.match(%r{https?://})

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
