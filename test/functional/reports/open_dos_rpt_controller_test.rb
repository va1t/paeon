require 'test_helper'

class Reports::OpenDosRptControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
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
