require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @patient = patients(:one)
    @subscriber = subscribers(:one)
    @deletable = subscribers(:three)
  end

  test "should get index" do
    sign_in @admin
    get :index, :patient_id => @patient.id
    assert_response :success
    assert_not_nil assigns(:subscribers)
  end

  test "should get new" do
    sign_in @admin
    get :new, :patient_id => @patient.id
    assert_response :success
  end

  test "should create subscriber" do
    sign_in @admin
    assert_difference('Subscriber.count') do
      post :create, subscriber: { patient_id: @subscriber.id, insurance_company_id: @subscriber.insurance_company_id,
                    insurance_company_id: @subscriber.insurance_company_id, ins_policy: @subscriber.ins_policy,            
                    ins_group: @subscriber.ins_group, ins_priority: @subscriber.ins_priority, subscriber_gender: @subscriber.subscriber_gender,
                    type_patient: @subscriber.type_patient, type_patient_other_description: @subscriber.type_patient_other_description,  
                    type_insurance: @subscriber.type_insurance, type_insurance_other_description: @subscriber.type_insurance_other_description,
                    employer_name: @subscriber.employer_name, employer_address1: @subscriber.employer_address1,
                    employer_city: @subscriber.employer_city, employer_state: @subscriber.employer_state, employer_zip: @subscriber.employer_zip, employer_phone: @subscriber.employer_phone },
                    :patient_id => @patient.id
      if assigns(:subscriber).errors.any?
        puts assigns(:subscriber).errors.inspect
      end      
    end
    assert_redirected_to patient_subscribers_path(:patient_id => @patient.id)
  end


  test "should show subscriber" do
    sign_in @admin
    get :show, id: @subscriber, :patient_id => @patient.id
    assert_response :success
  end


  test "should get edit" do
    sign_in @admin
    get :edit, id: @subscriber, :patient_id => @patient.id
    assert_response :success
  end


  test "should update subscriber" do
    sign_in @admin
    put :update, id: @subscriber, subscriber: { patient_id: @subscriber.id, insurance_company_id: @subscriber.insurance_company_id,
                 insurance_company_id: @subscriber.insurance_company_id, ins_policy: @subscriber.ins_policy,            
                 ins_group: @subscriber.ins_group, ins_priority: @subscriber.ins_priority,
                 type_patient: @subscriber.type_patient, type_patient_other_description: @subscriber.type_patient_other_description,  
                 type_insurance: @subscriber.type_insurance, type_insurance_other_description: @subscriber.type_insurance_other_description},
                 :patient_id => @patient.id
    assert_redirected_to patient_subscribers_path(:patient_id => @patient.id)
  end


  test "should destroy subscriber" do
    sign_in @admin
    assert_difference('Subscriber.count', -1) do
      delete :destroy, id: @deletable, :patient_id => @patient.id
      if assigns(:subscriber).errors.any?
        puts assigns(:subscriber).errors.inspect
      end  
    end
    assert_redirected_to patient_subscribers_path
  end

  test "should not destroy subscriber" do
    sign_in @admin
    assert_difference('Subscriber.count', 0) do
      delete :destroy, id: @subscriber, :patient_id => @patient.id
    end
    assert_redirected_to patient_subscribers_path
  end

end
