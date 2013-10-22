require 'test_helper'

class InsuredTypesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @insured_type = insured_types(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:insured_types)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create insured_type" do
    sign_in @admin
    assert_difference('InsuredType.count') do
      post :create, insured_type: { name: @insured_type.name }
    end

    assert_redirected_to insured_types_path
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @insured_type
    assert_response :success
  end

  test "should update insured_type" do
    sign_in @admin
    put :update, id: @insured_type, insured_type: { name: @insured_type.name }
    assert_redirected_to insured_types_path
  end

  test "should destroy insured_type" do
    sign_in @admin
    assert_difference('InsuredType.count', -1) do
      delete :destroy, id: @insured_type
    end

    assert_redirected_to insured_types_path
  end
end
