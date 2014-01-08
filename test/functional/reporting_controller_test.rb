require 'test_helper'

class ReportingControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin = users(:admin)
  end
  
  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
  end

end
