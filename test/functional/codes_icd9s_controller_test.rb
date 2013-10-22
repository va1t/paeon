require 'test_helper'

class CodesIcd9sControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @codes_icd9 = codes_icd9s(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:codes_icd9s)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create codes_icd9" do
    sign_in @admin
    assert_difference('CodesIcd9.count') do
      post :create, codes_icd9: { code: @codes_icd9.code, created_user: @codes_icd9.created_user, deleted: @codes_icd9.deleted, long_description: @codes_icd9.long_description, short_description: @codes_icd9.short_description, updated_user: @codes_icd9.updated_user }
    end

    assert_redirected_to codes_icd9_path(assigns(:codes_icd9))
  end

  test "should show codes_icd9" do
    sign_in @admin
    get :show, id: @codes_icd9
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @codes_icd9
    assert_response :success
  end

  test "should update codes_icd9" do
    sign_in @admin
    put :update, id: @codes_icd9, codes_icd9: { code: @codes_icd9.code, created_user: @codes_icd9.created_user, deleted: @codes_icd9.deleted, long_description: @codes_icd9.long_description, short_description: @codes_icd9.short_description, updated_user: @codes_icd9.updated_user }
    assert_redirected_to codes_icd9_path(assigns(:codes_icd9))
  end

  test "should destroy codes_icd9" do
    sign_in @admin
    assert_difference('CodesIcd9.count', -1) do
      delete :destroy, id: @codes_icd9
    end

    assert_redirected_to codes_icd9s_path
  end
end
