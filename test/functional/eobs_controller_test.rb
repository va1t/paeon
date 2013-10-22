require 'test_helper'

class EobsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @eob = eobs(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:eobs)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create eob" do
    sign_in @admin
    assert_difference('Eob.count') do
      post :create, eob: { claim_number: @eob.claim_number, eob_date: @eob.eob_date, group_number: @eob.group_number, patient_id: @eob.patient_id, 
           insurance_billing_id: @eob.insurance_billing_id, payment_amount: @eob.payment_amount, payor_name: @eob.payor_name, 
           subscriber_first_name: @eob.subscriber_first_name, subscriber_last_name: @eob.subscriber_last_name, subscriber_amount: @eob.subscriber_amount, 
           charge_amount: @eob.charge_amount }
      if assigns(:eob).errors.any?
        puts assigns(:eob).errors.inspect
      end
    end
    assert_redirected_to edit_eob_path(assigns(:eob))
  end


  test "should get edit" do
    sign_in @admin
    get :edit, id: @eob
    assert_response :success
  end

  test "should update eob" do    
    sign_in @admin
    put :update, id: @eob, eob: { claim_number: @eob.claim_number, eob_date: @eob.eob_date, group_number: @eob.group_number, 
        insurance_billing_id: @eob.insurance_billing_id, payment_amount: @eob.payment_amount, payor_name: @eob.payor_name, 
        subscriber_first_name: @eob.subscriber_first_name, subscriber_last_name: @eob.subscriber_last_name, subscriber_amount: @eob.subscriber_amount, 
        charge_amount: @eob.charge_amount }
    assert_redirected_to eob_path(@eob)
  end

  test "should destroy eob" do
    sign_in @admin
    assert_difference('Eob.count', -1) do
      delete :destroy, id: @eob
    end
    # the referer is nil, so should redirect to home page
    assert_redirected_to home_index_path
  end
end
