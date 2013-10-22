require 'test_helper'

class OfficeTypesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice) 
    @office_type = office_types(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:office_types)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create office_type" do
    sign_in @admin
    assert_difference('OfficeType.count') do
      post :create, office_type: { name: @office_type.name, perm: @office_type.perm, created_user: @office_type.created_user }
    end

    assert_redirected_to office_types_path
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @office_type
    assert_response :success
  end

  test "should update office_type" do
    sign_in @admin
    put :update, id: @office_type, office_type: { name: @office_type.name, perm: @office_type.perm, created_user: @office_type.created_user }
    assert_redirected_to office_types_path
  end

  test "should destroy office_type" do
    sign_in @admin
    assert_difference('OfficeType.count', -1) do
      delete :destroy, id: @office_type
    end

    assert_redirected_to office_types_path
  end
end
