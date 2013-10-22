require 'test_helper'

class ProcessingControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
  end

  test "should get claim_ready" do
    sign_in @admin
    get :claim_ready
    assert_response :success
  end

  test "should get claim_submitted" do
    sign_in @admin
    get :claim_submitted
    assert_response :success
  end

  test "should get claim_advice" do
    sign_in @admin
    get :view_advice
    assert_redirected_to office_ally_display_files_index_path    
  end

  test "should get session_history" do
    sign_in @admin
    get :session_history
    assert_response :success
  end

  test "revert claim for processing" do
    assert true
  end
  
  test "submit claims" do
    assert true
  end

end
