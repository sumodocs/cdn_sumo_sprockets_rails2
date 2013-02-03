require "test_helper"

class SprocketRails2Test < ActionController::IntegrationTest
  def test_add_rails_asset_pipeline
    assert Rails.asset_pipeline.instance_of? Sprockets::Environment
  end

  def test_fingerprint_in_stylesheet_urls
    get "/test"
    assert response.body =~ /test-65a13fe6d5f53bd73b2b5623bf8ef244.css/
  end

  def test_fingerprint_in_javascript_urls
    get "/test"
    assert response.body =~ /application-40dee5efe056d7299ee6c103223d7335.js/
  end

  def test_fingerprint_in_image_urls
    get "/test"
    assert response.body =~ /rails-ff9aaa136b36bf525402d4a0b436420f.png/
  end

  def test_respond_to_requests_under_assets
    get "/assets/rails-ff9aaa136b36bf525402d4a0b436420f.png"
    assert_response :success
  end

  def test_should_not_modify_url_for_non_existing_assets
    get "/test"
    assert response.body =~ %r{http://www.example.com/non-existing-file.png}
  end

  def test_respond_with_404_for_assets_with_invalid_fingerprint
    get "/assets/rails-db31f719034fzzaqeee4.png"
    assert_response :missing
  end
end
