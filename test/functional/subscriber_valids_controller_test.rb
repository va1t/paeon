require 'test_helper'

class SubscriberValidsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)   
    @patients_providers = patients_providers(:one)
    @valid = subscriber_valids(:one)
    @subscriber = subscribers(:one)
  end
  
  test "should get new" do
    sign_in @admin
    get :new, patients_provider_id: @patients_providers, subscriber_id: @subscriber
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, patients_provider_id: @patients_providers, id: @valid
    assert_response :success
  end

  test "should get create" do
    sign_in @admin
    post :create, patients_provider_id: @patients_providers
    assert_response :redirect
    assert_redirected_to patient_path(@patients_providers.patient_id)
  end

  test "should get update" do
    sign_in @admin
    put :update, patients_provider_id: @patients_providers, id: @valid
    assert_response :redirect
    assert_redirected_to patient_path(@patients_providers.patient_id)
  end

  test "should get destroy" do
    sign_in @admin
    delete :destroy, patients_provider_id: @patients_providers, id: @valid
    assert_response :redirect
    assert_redirected_to patient_path(@patients_providers.patient_id)
  end

end
