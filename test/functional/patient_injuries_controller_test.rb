require 'test_helper'

class PatientInjuriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @patient = patients(:one)
    @patient_injury = patient_injuries(:one)
    @deletable = patient_injuries(:three)
  end

  test "should get index" do
    sign_in @admin
    get :index, :patient_id => @patient.id
    assert_response :success
    assert_not_nil assigns(:patient_injuries)
  end

  test "should get new" do
    sign_in @admin
    get :new, :patient_id => @patient.id
    assert_response :success
  end

  test "should create patient_injury" do
    sign_in @admin
    assert_difference('PatientInjury.count') do
      post :create, :patient_id => @patient.id,
                    patient_injury: { patient_id: @patient_injury.patient_id, description: @patient_injury.description, 
                    start_illness: @patient_injury.start_illness, start_therapy: @patient_injury.start_therapy,
                    hospitalization_start: @patient_injury.hospitalization_start, hospitalization_stop: @patient_injury.hospitalization_stop,
                    disability_start: @patient_injury.disability_start, disability_stop: @patient_injury.disability_stop, 
                    accident_type: @patient_injury.accident_type, accident_description: @patient_injury.accident_description,
                    accident_state: @patient_injury.accident_state } 
      
      if assigns(:patient_injury).errors.any?
        puts assigns(:patient_injury).errors.inspect
      end      
    end
    assert_redirected_to patient_patient_injuries_path(:patient_id => @patient.id)
  end

  test "should show patient_injury" do
    sign_in @admin
    get :show, id: @patient_injury, :patient_id => @patient.id
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @patient_injury, :patient_id => @patient.id
    assert_response :success
  end

  test "should update patient_injury" do
    sign_in @admin
    put :update, :patient_id => @patient.id, id: @patient_injury, 
                 patient_injury: { patient_id: @patient_injury.patient_id, description: @patient_injury.description, 
                    start_illness: @patient_injury.start_illness, start_therapy: @patient_injury.start_therapy,
                    hospitalization_start: @patient_injury.hospitalization_start, hospitalization_stop: @patient_injury.hospitalization_stop,
                    disability_start: @patient_injury.disability_start, disability_stop: @patient_injury.disability_stop, 
                    accident_type: @patient_injury.accident_type, accident_description: @patient_injury.accident_description, accident_state: @patient_injury.accident_state } 
                    
    if assigns(:patient_injury).errors.any?
      puts assigns(:patient_injury).errors.inspect
    end      
    assert_redirected_to patient_patient_injuries_path(:patient_id => @patient.id)
  end

  test "should destroy patient_injury" do
    sign_in @admin
    assert_difference('PatientInjury.count', -1) do
      delete :destroy, id: @deletable, :patient_id => @patient.id
      if assigns(:patient_injury).errors.any?
        puts assigns(:patient_injury).errors.inspect
      end  
    end
    assert_redirected_to patient_patient_injuries_path :patient_id => @patient.id
  end

  test "should not destroy patient_injury" do
    sign_in @admin
    assert_difference('PatientInjury.count', 0) do
      delete :destroy, id: @patient_injury, :patient_id => @patient.id
    end
    assert_redirected_to patient_patient_injuries_path :patient_id => @patient.id
  end

end
