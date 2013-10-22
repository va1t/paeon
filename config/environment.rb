# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Monalisa::Application.initialize!


if (Rails.env == 'development')
  Rails.logger = Logger.new(STDOUT)
end



