module ActionView
  module Helpers
    def rewrite_asset_path(source)
      source = source.gsub(/^\//, "")  # remove the leading /
      source = source.gsub(/^images\/|^stylesheets\/|^javascripts\//, "") # remove leading images/ stylesheets/ or javascripts/
      if asset = Rails.asset_pipeline.find_asset(source)
        File.join("/assets/", asset.digest_path)
      else
        "/#{source}"
      end
    end
    alias :asset_path :rewrite_asset_path
  end
end
