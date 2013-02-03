require 'sprockets'

module Rails
  class << self
    def asset_pipeline
      @asset_pipeline ||= initialize_pipeline
    end

    def initialize_pipeline
      sprockets = Sprockets::Environment.new
      sprockets.append_path(File.join(Rails.root, "app/assets/javascripts"))
      sprockets.append_path(File.join(Rails.root, "app/assets/stylesheets"))
      sprockets.append_path(File.join(Rails.root, "app/assets/images"))

      sprockets.context_class.instance_eval do
        include ActionView::Helpers
      end
      sprockets
    end
  end
end