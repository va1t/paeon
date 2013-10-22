ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  
  # errors is the array of errors passed back on the object being evaluated
  # message is the error message that you are expecting back
  def assert_errors (errors, message)      
      errors.each do |e|       
        if e == message
          return assert_equal e, message
        end
      end
      # didnt find the expected error message, so return false
      return flunk "  Object Inspection => assert_errors: #{errors}, #{message}"
  end
  
  #test the validate_presence_of 
  #pass in the object to test and a list of symbols
  def validate_presence_of (object, *symbol)
    symbol.each do |sym|
      #Rails::logger.debug "Test_Presence_of: symbol: #{sym}"
      assert_errors object.errors[sym], I18n.translate('errors.messages.blank')
    end
  end
  
  # in the functional and integration tests, checks to confirm the public menu and footer  
  # is displayed when the user is logged out
  def public_menu_displayed
    assert_tag :tag => "a", :attributes => { :href => "/home/index"}, :content => "Home"
    assert_tag :tag => "a", :attributes => { :href => "/users/sign_in"}, :content => "Login"
    assert_no_tag :tag => "a", :content => "Users"
    assert_no_tag :tag => "a", :content => "Logout"
  end
  
  # in the functional and integrations tests, checks to confirm the private menu and footer 
  # is displayed when the user is logged into the system
  def loggedin_menu_displayed
    assert_tag :tag => "a", :attributes => { :href => "/home/index"}, :content => "Home"
    assert_tag :tag => "a", :attributes => { :href => "/users/sign_out"}, :content => "Logout"    
    assert_no_tag :tag => "a", :content => "Login"
  end

  
end
