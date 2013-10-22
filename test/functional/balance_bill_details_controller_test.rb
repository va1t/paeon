require 'test_helper'

class BalanceBillDetailsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin = users(:admin)
    @session = insurance_sessions(:one)
    @detail = balance_bill_details(:one)
  end

  test "should get destroy" do
    sign_in @admin
    get :destroy, insurance_session_id: @session.id, id: @detail.id
    assert_redirected_to edit_insurance_session_balance_bill_session_path insurance_session_id: @session.id, id: @detail.balance_bill_session_id
    assert_response :redirect
  end

end
