require 'test_helper'

class DataerrorControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @patient = patients(:one)    
    @group = groups(:one)
    @provider = providers(:one)
    @session = insurance_sessions(:one)
    @billing = insurance_billings(:one)
    @balance_bill = balance_bills(:one)
  end

  test "should get index with patient" do
    sign_in @admin
    get :index, patient_id: @patient.id
    assert_response :success
  end  
  
  test "should get index with group" do
    sign_in @admin
    get :index, group_id: @group.id
    assert_response :success    
  end
  
  test "should get index with provider" do
    sign_in @admin
    get :index, provider_id: @provider.id
    assert_response :success    
  end

  test "should get index with balance bill" do
    sign_in @admin
    get :balance_bill_index, balance_bill_id: @balance_bill.id
    assert_response :success    
  end

  test "should get index with billing" do
    sign_in @admin
    get :insurance_billing_index, insurance_billing_id: @billing.id 
    assert_response :success    
  end

  test "should get the override error page " do
    sign_in @admin
    @billing.update_attributes(:subscriber_id => nil, :skip_callbacks => true)
    get :insurance_billing_override, insurance_billing_id: @billing.id
    assert_response :success
  end
end
