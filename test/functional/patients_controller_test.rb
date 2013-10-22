require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)   
    @patient = patients(:one)
    @deletable = patients(:three)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:patients)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create patient" do
    sign_in @admin  
    assert_difference('Patient.count') do
      post :create, patient: { first_name: @patient.first_name, last_name: @patient.last_name,
                              address1: @patient.address1, address2: @patient.address2, city: @patient.city, state: @patient.state, zip: @patient.zip,
                              home_phone: @patient.home_phone, work_phone: @patient.work_phone, cell_phone: @patient.cell_phone, 
                              ssn_number: @patient.ssn_number, gender: @patient.gender, patient_status: @patient.patient_status, 
                              dob: @patient.dob, relationship_status: @patient.relationship_status, created_user: @admin.login_name }
      if assigns(:patient).errors.any?
        puts assigns(:patient).errors.inspect
        assigns(:patient).errors.full_messages.each { |msg| puts msg }
      end      
    end

    assert_redirected_to patient_path(assigns(:patient))
  end


  test "should show patient" do
    sign_in @admin
    get :show, id: @patient
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @patient
    assert_response :success
  end

  test "should update patient" do
    sign_in @admin
    put :update, id: @patient, patient: { address1: @patient.address1, address2: @patient.address2, cell_phone: @patient.cell_phone, 
                                        city: @patient.city, first_name: @patient.first_name,  
                                        gender: @patient.gender, home_phone: @patient.home_phone, 
                                        last_name: @patient.last_name, ssn_number: @patient.ssn_number, 
                                        state: @patient.state, work_phone: @patient.work_phone, zip: @patient.zip }
    assert_redirected_to patient_path(assigns(:patient))
  end


  test "should destroy patient" do
    sign_in @admin
    assert_difference('Patient.count', -1) do
      delete :destroy, id: @deletable
      if assigns(:patient).errors.any?
        puts assigns(:patient).errors.inspect
      end            
    end
    assert_redirected_to patients_path
  end

  test "should not destroy patient" do
    sign_in @admin
    assert_difference('Patient.count', -0) do
      delete :destroy, id: @patient
    end
    assert_redirected_to patients_path
  end

end
