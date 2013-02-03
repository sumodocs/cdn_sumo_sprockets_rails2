$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'minitest/spec'

ENV['RAILS_ENV'] = 'test'
require 'dummy/config/environment'
require 'test_help'
