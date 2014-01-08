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
    assert_difference('BalanceBillPayment.count') do
      post :create, balance_bill_id: @bb_payment.balance_bill_id, balance_bill_payment: {payment_amount: @bb_payment.payment_amount,
                  created_user: @bb_payment.created_user, unformatted_payment_date: "10/09/2013", check_number: @bb_payment.check_number,
                  payment_method: @bb_payment.payment_method}
    end
    assert_response :redirect
    balance_bill = assigns(:balance_bill)
    assert_redirected_to balance_bill_path(balance_bill.id)
  end


  test "should get update" do
    sign_in @admin
    put :update, balance_bill_id: @bb_payment.balance_bill_id, id: @bb_payment, balance_bill_payment: {payment_amount: @bb_payment.payment_amount,
                  created_user: @bb_payment.created_user, unformatted_payment_date: "10/09/2013", check_number: @bb_payment.check_number,
                  payment_method: @bb_payment.payment_method}
    assert_response :redirect
    assert_redirected_to balance_bill_path, id: @bb_payment.balance_bill_id
  end

end
