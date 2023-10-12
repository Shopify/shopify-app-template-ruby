# frozen_string_literal: true
require 'pathname'

namespace :build do
  desc "Run all build tasks"
  task all: ["assets:precompile", :build_frontend_links]

  desc "Build symlinks for FE assets"
  task build_frontend_links: :environment do
    # Define paths using Pathname
    index_path = Pathname.new(File.join(__dir__, "../../public/dist/index.html"))
    assets_path = Pathname.new(File.join(__dir__, "../../public/assets"))

    # Targets for the symlinks
    index_target = Pathname.new(File.join(__dir__, "../../frontend/dist/index.html"))
    assets_target = Pathname.new(File.join(__dir__, "../../frontend/dist/assets"))

    # Compute relative paths
    relative_index_target = index_target.relative_path_from(index_path.dirname)
    relative_assets_target = assets_target.relative_path_from(assets_path.dirname)

    # Create symlinks if they don't already exist
    index_path.make_symlink(relative_index_target) unless index_path.symlink?
    assets_path.make_symlink(relative_assets_target) unless assets_path.symlink?
  end
end
