ENV["RAILS_ENV"] ||= 'test'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "nfg_onboarder"
require File.expand_path("../dummy/config/environment", __FILE__)
