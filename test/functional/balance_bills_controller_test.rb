require 'test_helper'

class BalanceBillsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @balance_bill = balance_bills(:one)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @balance_bill
    assert_response :success
  end

  test "should get create" do
#    sign_in @admin
#    get :create
#    assert_response :success
  end

  test "should get update" do
    sign_in @admin
    put :update, id: @balance_bill
    assert_response :redirect
    assert_redirected_to balance_bill_path, id: @balance_bill
  end

  test "should get update & stay in edit" do
    sign_in @admin
    put :update, id: @balance_bill, commit: "Update"
    assert_response :success
  end

  test "should get destroy" do
    sign_in @admin
    delete :destroy, id: @balance_bill
    assert_response :redirect
    assert_redirected_to balance_bills_path
  end
end
