require 'test_helper'

class IdiagnosticsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)   
    @patients_providers = patients_providers(:one)    
    @idiagnostic = idiagnostics(:one)
  end

  test "should get new" do
    sign_in @admin
    get :new, patients_provider_id: @patients_providers.id
    assert_response :success
    assert_not_nil assigns(:idiagnostic)
  end

  test "should create idiagnostic" do
    sign_in @admin
    assert_difference('Idiagnostic.count') do
      post :create, patients_provider_id: @patients_providers.id, idiagnostic: { dsm_code: "309", created_user: @idiagnostic.created_user }
      if assigns(:idiagnostic).errors.any?
        puts assigns(:idiagnostic).errors.inspect
      end
    end

    assert_redirected_to patient_path(@patients_providers.patient_id)
  end

  test "should destroy idiagnostic" do   
    sign_in @admin
    assert_difference('Idiagnostic.count', -1) do
      delete :destroy, patients_provider_id: @patients_providers.id, id: @idiagnostic
    end
    assert_redirected_to patients_provider_path(@patients_providers)    
  end
end
