require 'test_helper'

class BalanceBillPaymentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin = users(:admin)
    @balance_bill = balance_bills(:one)
    @bb_payment = balance_bill_payments(:one)
  end

  test "should get new" do
    sign_in @admin
    get :new, balance_bill_id: @bb_payment.balance_bill_id
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, balance_bill_id: @bb_payment.balance_bill_id, id: @bb_payment
    assert_response :success
  end

  test "should get create" do
    sign_in @admin
    get :create, balance_bill_id: @bb_payment.balance_bill_id
    assert_response :success
  end

  test "should get update" do
    sign_in @admin
    put :update, balance_bill_id: @bb_payment.balance_bill_id, id: @bb_payment
    assert_response :redirect
    assert_redirected_to balance_bill_path, id: @balance_bill
  end

end
