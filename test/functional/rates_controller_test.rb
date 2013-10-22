require 'test_helper'

class RatesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
 # all tests are performed froma patient perspective with the polmorphic notes class
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @rate = rates(:one)
    @provider = providers(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index, provider_id: @provider
    assert_response :success
    assert_not_nil assigns(:rates)
  end

  test "should get new" do
    sign_in @admin
    get :new, provider_id: @provider
    assert_response :success
  end

  test "should create rate" do
    sign_in @admin
    assert_difference('Rate.count') do
      post :create, provider_id: @provider, rate: { cpt_code: @rate.cpt_code, description: @rate.description, created_user: @rate.created_user }
    end

    assert_redirected_to provider_rates_path(:provider_id => @provider)
  end

  test "should show rate" do
    sign_in @admin
    get :show, provider_id: @provider, id: @rate
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, provider_id: @provider, id: @rate
    assert_response :success
  end

  test "should update rate" do
    sign_in @admin
    put :update, provider_id: @provider, id: @rate, rate: { cpt_code: @rate.cpt_code, description: @rate.description, created_user: @rate.created_user }
    assert_redirected_to provider_rates_path(provider_id: @provider)
  end

  test "should destroy rate" do
    sign_in @admin
    assert_difference('Rate.count', -1) do
      delete :destroy, provider_id: @provider, id: @rate
    end

    assert_redirected_to provider_rates_path(provider_id: @provider)
  end
end
