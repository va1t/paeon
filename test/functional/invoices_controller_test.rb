require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice_user = users(:invoice)
    @invoice = invoices(:one)    
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success   
  end

  #test "should get new" do
  #  sign_in @admin
  #  get :new
  #  assert_response :success
  #end

  test "should create invoice" do
    sign_in @admin
    assert_difference('Invoice.count') do
      post :create, invoice: { closed_date: @invoice.closed_date, created_date: @invoice.created_date, balance_owed_amount: @invoice.balance_owed_amount, 
                               sent_date: @invoice.sent_date, status: @invoice.status, total_invoice_amount: @invoice.total_invoice_amount,
                               invoiceable_type: "Providers", invoiceable_id: 1 }
    end

    assert_redirected_to invoices_path(:group_id => @invoice.invoiceable_id)
  end

  #test "should show invoice" do
  #  sign_in @admin
  #  get :show, id: @invoice
  #  assert_response :success
  #end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @invoice
    assert_response :success
  end

  test "should update invoice" do
    sign_in @admin
    put :update, id: @invoice, invoice: { closed_date: @invoice.closed_date, created_date: @invoice.created_date, balance_owed_amount: @invoice.balance_owed_amount, 
                                          sent_date: @invoice.sent_date, status: @invoice.status, total_invoice_amount: @invoice.total_invoice_amount }
    assert_redirected_to invoices_path(:group_id => @invoice.invoiceable_id)
  end

  test "should destroy invoice" do    
    sign_in @admin
    assert_difference('Invoice.count', -1) do
      delete :destroy, id: @invoice
    end

    assert_redirected_to invoices_path(:group_id => @invoice.invoiceable_id)
  end
end
