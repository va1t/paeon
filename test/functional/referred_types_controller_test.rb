require 'test_helper'

class ReferredTypesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @referred_type = referred_types(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:referred_types)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create referred_type" do
    sign_in @admin
    assert_difference('ReferredType.count') do
      post :create, referred_type: { created_user: @referred_type.created_user, referred_type: @referred_type.referred_type, updated_user: @referred_type.updated_user }
    end

    assert_redirected_to referred_types_path()
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @referred_type
    assert_response :success
  end

  test "should update referred_type" do
    sign_in @admin
    put :update, id: @referred_type, referred_type: { created_user: @referred_type.created_user, referred_type: @referred_type.referred_type, updated_user: @referred_type.updated_user }
    assert_redirected_to referred_types_path()
  end

  test "should destroy referred_type" do
    sign_in @admin
    assert_difference('ReferredType.count', -1) do
      delete :destroy, id: @referred_type
    end

    assert_redirected_to referred_types_path
  end
end
