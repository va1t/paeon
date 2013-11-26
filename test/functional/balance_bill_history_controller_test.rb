require 'test_helper'

class BalanceBillHistoryControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @balance_bill = balance_bills(:one)
    @patient = patients(:one)
    @provider = providers(:one)
  end


  test "should get patient" do
    sign_in @admin
    get :patient, id: @patient
    assert_response :success
  end

  test "should get provider" do
    sign_in @admin
    get :provider, id: @provider
    assert_response :success
  end

end
