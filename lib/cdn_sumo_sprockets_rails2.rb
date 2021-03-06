require 'sprockets'

module CdnSumoSprockets
  def self.new
    sprockets = Sprockets::Environment.new
    sprockets.append_path(File.join('.', "app/assets/javascripts"))
    sprockets.append_path(File.join('.', "app/assets/stylesheets"))
    sprockets.append_path(File.join('.', "app/assets/images"))
    sprockets
  end

  def self.root
    Pathname.new('.')
  end

  def self.public_path
    root.join("public")
  end
end


require 'cdn_sumo_sprockets_rails2/rails2/asset_helpers'
require 'cdn_sumo_sprockets_rails2/rails2/asset_pipeline'
require 'cdn_sumo_sprockets_rails2/rails2/middleware'


if defined?(ActionController)
  ActionController::Dispatcher.middleware.use Sprockets::Rails2::Middleware

  ActionController::Base.asset_host = Proc.new { |source, request|
    if host = ENV['CDN_SUMO_URL']
      "#{request.protocol}#{host}"
    else
      "#{request.protocol}#{request.host_with_port}"
    end
  }
end
