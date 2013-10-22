require 'test_helper'

class InsuranceSessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
 
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @session1 = insurance_sessions(:one)
    @deletable = insurance_sessions(:three)
    @patient = patients(:one)
    @provider = providers(:one)
    @office = offices(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
  end

  test "should get new" do
    sign_in @admin    
    get :new, patient_id: @patient.id  
    assert_response :success    
  end

  test "create insurance session redirect to claim" do
    sign_in @admin
    assert_difference("InsuranceSession.count") do
      post :create, insurance_session: {unformatted_service_date: Date.today.strftime("%m/%d/%Y"), provider_id: @provider.id, selector: Selector::PROVIDER, office_id: @office.id, 
                  billing_office_id: @office.id, pos_code: "11", patient_copay: "0.00", patient_id: @patient.id, status: BillingFlow::INITIATE, 
                  created_user: @admin.login_name }, commit: "Insurance Claim"
    end
    assert_redirected_to insurance_session_insurance_billings_path( assigns(:insurance_session) )
  end
  
  test "create insurance session redirect to balace bill" do
    sign_in @admin
    assert_difference("InsuranceSession.count") do
      post :create, insurance_session: {unformatted_service_date: Date.today.strftime("%m/%d/%Y"), provider_id: @provider.id, selector: Selector::PROVIDER, office_id: @office.id, 
                  billing_office_id: @office.id, pos_code: "11", patient_copay: "0.00", patient_id: @patient.id, status: BillingFlow::INITIATE, 
                  created_user: @admin.login_name }, commit: "Direct Bill"
    end
    assert_redirected_to new_insurance_session_balance_bill_session_path( assigns(:insurance_session) )
  end
  
  
  test "create session history on create" do
    sign_in @admin
    assert_difference("InsuranceSessionHistory.count") do
      post :create, insurance_session: {unformatted_service_date: Date.today.strftime("%m/%d/%Y"), provider_id: @provider.id, selector: Selector::PROVIDER, office_id: @office.id, 
                  billing_office_id: @office.id, pos_code: "11", patient_copay: "0.00", patient_id: @patient.id, status: BillingFlow::INITIATE, 
                  created_user: @admin.login_name }, commit: "Insurance Claim"
    end
  end
  
  
#  test "should get edit" do
#    sign_in @admin
#    get :edit
#    assert_response :success
#  end

#  test "should get update" do
#    sign_in @admin
#    get :update
#    assert_response :success
#  end

  test "should destroy insurance_session" do
    sign_in @admin
    assert_difference('InsuranceSession.count', -1) do
      delete :destroy, id: @deletable.id
      puts assigns(:insurance_session).errors.inspect if assigns(:insurance_session).errors.any?
    end
    assert_redirected_to insurance_sessions_path
  end
  
  test "destroy session history record" do
    sign_in @admin
    assert_difference('InsuranceSessionHistory.count', -1) do
      delete :destroy, id: @deletable.id
      puts assigns(:insurance_session).errors.inspect if assigns(:insurance_session).errors.any?
    end
    assert_redirected_to insurance_sessions_path
  end


  test "should not destroy insurance_session" do
    sign_in @admin
    #make sure the billing state is not deleteable    
    @session1.insurance_billings.each { |billing| billing.status = BillingFlow::SUBMITTED }
    @session1.save!        
    @session1.errors.full_messages.each {|msg| puts msg} if @session1.errors.any?
    assert_difference('InsuranceSession.count', 0) do
      delete :destroy, id: @session1.id
      #@result = assigns(:insurance_session)
      #@result.errors.full_messages.each {|msg| puts msg} if @result.errors.any? 
    end
    assert_redirected_to insurance_sessions_path
  end



end
