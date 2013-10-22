#
# This is the development Gemfile.
# During release, the ProdGemfile is copied to Gemfile
# This is to support the development of rails engines locally in development
# But use the gem version in production from github
#

source 'https://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'devise'

gem 'cancan'
gem 'date_validator'
gem 'exception_notification'
gem 'rubyzip', '0.9.9'
gem 'audited-activerecord'
gem 'prawn'
gem 'will_paginate'

# Rails Engines included here
gem 'office_ally', :path => '../office_ally'      
#gem 'office_ally', :git => 'git@github.com:mjpete3/officeally.git'  


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3'
end

group :tests do
  gem 'test-unit'
  gem 'capybara'
  gem 'bcrypt-ruby'
  gem 'ruby-prof'
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'debugger'
