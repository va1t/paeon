require "test_helper"
require "capybara/rails"

module ActionController
  class IntegrationTest
    include Capybara::DSL

    def set_host (host)
      host! host
      Capybara.app_host = "http://" + host
    end

    def log_in(user, password)
      visit "/"
      click_link "Login"
      fill_in 'User Name', :with => user
      fill_in 'Password', :with => password
      click_button 'Sign in'
    end
    
    def log_out
      click_link "Logout"
    end
          
  end
end

