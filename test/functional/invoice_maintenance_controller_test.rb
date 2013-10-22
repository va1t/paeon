require 'test_helper'

class InvoiceMaintenanceControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice_user = users(:invoice)
    @provider = providers(:one)
    @group = groups(:one)    
  end
  
  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
  end


  test "should put update provider" do
    sign_in @admin
    put :update, id: @provider.id, provider: { invoice_method: InvoiceCalculation::FLATFEE, flat_fee: @provider.flat_fee}
    assert_redirected_to invoice_maintenance_index_path
  end
  
  test "should put update group" do
    sign_in @admin
    put :update, id: @group.id, provider: { invoice_method: InvoiceCalculation::FLATFEE, flat_fee: @group.flat_fee}
    assert_redirected_to invoice_maintenance_index_path
  end


  test "should get show" do
    sign_in @admin
    get :show
    assert_response :success
  end
  

  test "should get print" do
    sign_in @admin
    get :print
    assert_response :success
  end

end
