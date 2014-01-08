require 'test_helper'

class InvoicePaymentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin = users(:admin)
    @invoice = invoices(:one)
    @inv_payment = invoice_payments(:one)
  end

  test "should get new" do
    sign_in @admin
    get :new, invoice_id: @invoice
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, invoice_id: @invoice, id: @inv_payment
    assert_response :success
  end

  test "should get create" do
    sign_in @admin
    get :create, invoice_id: @invoice
    assert_response :success
  end

  test "should get update" do
    sign_in @admin
    get :update, invoice_id: @invoice, id: @inv_payment
    assert_response :success
  end

end
