require 'test_helper'

class InsuranceTypesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @insurance_type = insurance_types(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:insurance_types)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create insurance_type" do
    sign_in @admin
    assert_difference('InsuranceType.count') do
      post :create, insurance_type: { name: @insurance_type.name }
    end

    assert_redirected_to insurance_types_path
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @insurance_type
    assert_response :success
  end

  test "should update insurance_type" do
    sign_in @admin
    put :update, id: @insurance_type, insurance_type: { name: @insurance_type.name }
    assert_redirected_to insurance_types_path
  end

  test "should destroy insurance_type" do
    sign_in @admin
    assert_difference('InsuranceType.count', -1) do
      delete :destroy, id: @insurance_type
    end

    assert_redirected_to insurance_types_path
  end
end
