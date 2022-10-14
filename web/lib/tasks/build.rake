# frozen_string_literal: true

namespace :build do
  desc "Run all build tasks"
  task all: ["assets:precompile", :build_frontend_links]

  desc "Build symlinks for FE assets"
  task build_frontend_links: :environment do
    dist_dir = File.expand_path("../../public/dist", __dir__)
    Dir.mkdir(dist_dir) unless File.exists?(dist_dir) 
  
    index_path = File.expand_path("../../public/dist/index.html", __dir__)
    assets_path = File.expand_path("../../public/assets", __dir__)

    File.symlink(File.expand_path("../../frontend/dist/index.html", __dir__), index_path) unless File.symlink?(index_path)
    File.symlink(File.expand_path("../../frontend/dist/assets", __dir__), assets_path) unless File.symlink?(assets_path)
  end
end
