
module Rails
  class << self
    def asset_pipeline
      @asset_pipeline ||= initialize_pipeline
    end

    def initialize_pipeline
      sprockets = CdnSumoSprockets.new
      sprockets.context_class.instance_eval do
        include ActionView::Helpers
      end
      sprockets
    end
  end
end
