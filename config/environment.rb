# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.active_record.observers = :transfer_observer

  config.action_controller.session = {
    :session_key => '_favpal_session',
    :secret      => IO.read('config/secret')
  }
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  config.active_record.default_timezone = :utc
end
if ENV['RAILS_ENV']=='production'
  URL='http://favpal.org'
else
  URL='http://localhost:3000'
end



