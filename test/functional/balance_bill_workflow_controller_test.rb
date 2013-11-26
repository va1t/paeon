require 'test_helper'

class BalanceBillWorkflowControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @balance_bill = balance_bills(:one)
    @balance_bill3 = balance_bills(:three)
  end

  test "should get show" do
    sign_in @admin
    get :show, id: @balance_bill
    assert_response :success
  end

  test "should get print" do
    sign_in @admin
    get :print, id: @balance_bill
    assert_response :success
  end

  test "should get waive" do
    sign_in @admin
    get :waive, id: @balance_bill
    assert_response :redirect
    assert_redirected_to balance_bill_path(@balance_bill)
  end

  test "should get revert" do
    sign_in @admin
    get :revert, id: @balance_bill
    assert_response :redirect
    assert_redirected_to balance_bill_path(@balance_bill)
  end

  test "should get close" do
    sign_in @admin
    get :close, id: @balance_bill3
    assert_response :redirect
    assert_redirected_to balance_bills_path
  end

end
