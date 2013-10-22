require 'test_helper'

class ManagedCaresControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @patient = patients(:one)    
    @managed_care = managed_cares(:one)
    @deletable = managed_cares(:three)
  end

  test "should get index" do
    sign_in @admin
    get :index, patient_id: @patient.id
    assert_response :success
    assert_not_nil assigns(:managed_cares)
  end

  test "should get new" do
    sign_in @admin
    get :new, patient_id: @patient.id
    assert_response :success
  end

  test "should create managed_care" do
    sign_in @admin
    assert_difference('ManagedCare.count') do
      post :create, patient_id: @patient.id,
                 :managed_care => { :patient_id => @patient.id, :subscriber_id => @managed_care.subscriber_id, :authorization_id => @managed_care.authorization_id, :authorized_charges => @managed_care.authorized_charges, 
                                    :authorized_sessions => @managed_care.authorized_sessions, :authorized_units => @managed_care.authorized_units, 
                                    :copay => @managed_care.copay, :"end_date(1i)" => "2013", :"end_date(2i)" => "10", :"end_date(3i)" => "15",  
                                    :"start_date(1i)" => "2012",:"start_date(2i)" => "09", :"start_date(3i)" => "15" }
      if assigns(:managed_care).errors.any?
        puts assigns(:managed_care).errors.inspect
      end
    end
    assert_redirected_to patient_managed_cares_path(patient_id: @patient.id)
  end

  test "should not create managed_care" do
    sign_in @admin
    assert_difference('ManagedCare.count', 0) do
      #subscriber_id is missing from post.  insert should fail
      post :create, patient_id: @patient.id,
                 :managed_care => { :patient_id => @patient.id, :authorization_id => @managed_care.authorization_id, :authorized_charges => @managed_care.authorized_charges, 
                                    :authorized_sessions => @managed_care.authorized_sessions, :authorized_units => @managed_care.authorized_units, 
                                    :copay => @managed_care.copay, :"end_date(1i)" => "2013", :"end_date(2i)" => "10", :"end_date(3i)" => "15",  
                                    :"start_date(1i)" => "2012",:"start_date(2i)" => "09", :"start_date(3i)" => "15" }
      assert assigns(:managed_care).errors.any?
    end
    assert_template :new
  end


  test "should show managed_care" do
    sign_in @admin
    get :show, id: @managed_care, patient_id: @patient.id
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @managed_care, patient_id: @patient.id
    assert_response :success
  end

  test "should update managed_care" do
    sign_in @admin
    put :update, patient_id: @patient.id, id: @managed_care, 
                     :managed_care => { :authorization_id => @managed_care.authorization_id, :authorized_charges => @managed_care.authorized_charges, 
                     :authorized_sessions => @managed_care.authorized_sessions, :authorized_units => @managed_care.authorized_units, :copay => @managed_care.copay, 
                     :used_charges => @managed_care.used_charges, :used_sessions => @managed_care.used_sessions, :used_units => @managed_care.used_units,
                     :"end_date(1i)" => "2013", :"end_date(2i)" => "10", :"end_date(3i)" => "15",  
                     :"start_date(1i)" => "2012",:"start_date(2i)" => "09", :"start_date(3i)" => "15", }
                     
    #assert_nil assigns(:managed_care).errors
    assert_redirected_to patient_managed_cares_path(patient_id: @patient.id)
  end

  test "should destroy managed_care" do
    sign_in @admin
    assert_difference('ManagedCare.count', -1) do
      delete :destroy, id: @deletable, :patient_id => @patient.id
      if assigns(:managed_care).errors.any?
        puts assigns(:managed_care).errors.inspect
      end  
    end
    assert_redirected_to patient_managed_cares_path(patient_id: @patient.id)
  end

  test "should not destroy managed_care" do
    sign_in @admin
    assert_difference('ManagedCare.count', 0) do
      delete :destroy, id: @managed_care, :patient_id => @patient.id      
    end
    assert_redirected_to patient_managed_cares_path(patient_id: @patient.id)
  end

end
