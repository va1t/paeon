require 'test_helper'

class InvoiceWorkflowControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice_user = users(:invoice)
    @invoice = invoices(:one)
    @invoice3 = invoices(:three)
  end

  test "should get show" do
    sign_in @admin
    get :show, id: @invoice
    assert_response :success
  end

  test "should get print" do
    sign_in @admin
    get :print, id: @invoice
    assert_response :success
  end

  test "should get waive" do
    sign_in @admin
    get :waive, id: @invoice
    assert_response :redirect
  end

  test "should get revert" do
    sign_in @admin
    get :revert, id: @invoice
    assert_response :redirect
  end

  test "should get close" do
    sign_in @admin
    get :close, id: @invoice3
    assert_response :redirect
  end

end
