require 'test_helper'

class InsuranceBillingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
 
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @insurance_billing = insurance_billings(:one)
    @notdeletable = insurance_billings(:three)
    @insurance_session = insurance_sessions(:one)
    @no_claims= insurance_sessions(:four)
    @eob = eobs(:one)
  end


  test "should get index" do
    sign_in @admin
    get :index, {insurance_session_id: @insurance_session.id}, {"patient" => @insurance_session.patient_id.to_s, 'warden.user.user.key' => session['warden.user.user.key']}
    assert_response :success
    assert_not_nil assigns(:insurance_billings)
  end


  test "should get new" do
    sign_in @admin
    get :new, insurance_session_id: @no_claims.id
    #dump any error messages
    session = assigns(:insurance_session)
    session.errors.full_messages.each {|msg| puts "session: #{msg}"} if session.errors.any?
    billing = assigns(:insurance_billing)
    billing.errors.full_messages.each {|msg| puts "billing: #{msg}"} if billing.errors.any?
    assert_redirected_to insurance_session_insurance_billings_path
  end


  #test "history table updatd on new" do
  #  sign_in @admin    
  #  assert_difference("InsuranceBillingHistory.count") do
  #    get :new, insurance_session_id: @no_claims.id 
  #  end
  #end


  test "should update insurance_billing" do
    sign_in @admin
    session[:patient] = @insurance_session.patient_id.to_s
    put :update, insurance_session_id: @insurance_session.id, id: @insurance_billing.id,  
        insurance_billing: { insurance_session_id: @insurance_billing.insurance_session_id , 
                             claim_number: @insurance_billing.claim_number, claim_submitted: @insurance_billing.claim_submitted, 
                             insurance_billed: @insurance_billing.insurance_billed, status: @insurance_billing.status}
    if assigns(:insurance_billing).errors.any?
      puts assigns(:insurance_billing).errors.inspect
    end                             
    assert_redirected_to insurance_sessions_path
  end

  
#  test "history table update on update" do
#    sign_in @admin
#    session[:patient] = @insurance_session.patient_id.to_s
#    assert_difference("InsuranceBillingHistory.count") do
#      put :update, insurance_session_id: @insurance_session.id, id: @insurance_billing.id,  
#        insurance_billing: { insurance_session_id: @insurance_billing.insurance_session_id , 
#                             claim_number: @insurance_billing.claim_number, claim_submitted: @insurance_billing.claim_submitted, 
#                             insurance_billed: @insurance_billing.insurance_billed, status: BillingFlow::PAID}    
#    end
#  end


  test "should destroy insurance_billing" do
    sign_in @admin
    assert_difference('InsuranceBilling.count', -1) do
      delete :destroy, insurance_session_id: @insurance_session.id, id: @insurance_billing.id
    end
    assert_redirected_to insurance_session_insurance_billings_path(insurance_session_id: @insurance_session.id)
  end


  test "should destroy history records" do
    sign_in @admin
    assert_difference('InsuranceBillingHistory.count', -1) do
      delete :destroy, insurance_session_id: @insurance_session.id, id: @insurance_billing.id
    end    
  end
  
  test "should not destroy insurance_billing" do
    sign_in @admin
    assert_difference('InsuranceBilling.count', 0) do
      delete :destroy, insurance_session_id: @insurance_session.id, id: @notdeletable.id
    end
    assert_redirected_to insurance_session_insurance_billings_path(insurance_session_id: @insurance_session.id)
  end
  
  test "create secondary claim" do
    sign_in @admin
    assert_difference('InsuranceBilling.count') do
      get :secondary, insurance_session_id: @insurance_session.id, insurance_billing_id: @insurance_billing.id
    end
    assert_equal assigns(:claim).status, BillingFlow::CLOSED
    assert_redirected_to insurance_session_insurance_billings_path(@insurance_session.id)
  end
  
  test "waive a claim" do
    sign_in @admin
    # this claim also points to session :one so we have ot close it to test the waiving    
    @notdeletable.update_attributes(:status => BillingFlow::CLOSED)
    
    get :waive, insurance_session_id: @insurance_session.id, insurance_billing_id: @insurance_billing.id, eob_id: @eob.id    
    session = assigns(:insurance_session)
    claim = assigns(:claim)
    
    session.errors.full_messages.each {|msg| puts msg} if session.errors.any?
    claim.errors.full_messages.each {|msg| puts msg} if claim.errors.any?
    
    assert_equal session.status, SessionFlow::CLOSED
    assert_equal claim.status, BillingFlow::CLOSED
    assert session.balance_owed = 0
    assert_redirected_to eobs_path
  end
  
  test "create balance bill" do
    sign_in @admin
    get :balance, insurance_session_id: @insurance_session.id, insurance_billing_id: @insurance_billing.id
    assert_equal assigns(:claim).status, BillingFlow::CLOSED
    assert_redirected_to new_insurance_session_balance_bill_session_path(@insurance_session.id)
  end
end
